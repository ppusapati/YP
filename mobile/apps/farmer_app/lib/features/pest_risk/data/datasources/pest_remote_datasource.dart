import 'package:flutter_network/flutter_network.dart';
import 'package:flutter_proto/src/generated/pest.pb.dart' hide RiskLevel, AlertStatus;
import 'package:flutter_proto/src/generated/pest.pbenum.dart' as pest_proto;
import 'package:logging/logging.dart';
import 'package:protobuf/protobuf.dart' as $pb;

import '../../domain/entities/pest_risk_entity.dart' show RiskLevel;
import '../models/pest_risk_model.dart';

/// Remote data source for pest risk data, backed by ConnectRPC.
abstract class PestRemoteDataSource {
  Future<List<PestRiskZoneModel>> fetchPestRiskZones({String? fieldId});
  Future<List<PestAlertModel>> fetchPestAlerts({String? fieldId});
  Future<PestAlertModel> fetchPestAlertById(String alertId);
  Future<void> markAlertAsRead(String alertId);
}

class PestRemoteDataSourceImpl implements PestRemoteDataSource {
  PestRemoteDataSourceImpl({required ConnectClient client}) : _client = client;

  final ConnectClient _client;
  static final _log = Logger('PestRemoteDataSource');
  static const _basePath = '/agriculture.pest.v1.PestPredictionService';

  Future<ConnectResponse> _call(
      String method, $pb.GeneratedMessage request) async {
    final response = await _client.unary(
      '$_basePath/$method',
      body: request.writeToBuffer(),
    );
    if (!response.isSuccess) {
      throw ConnectException(
        code: 'internal',
        message: '$_basePath/$method failed',
        statusCode: response.statusCode,
      );
    }
    return response;
  }

  @override
  Future<List<PestRiskZoneModel>> fetchPestRiskZones({String? fieldId}) async {
    // NOTE: The proto has no GetPestRiskZones RPC. The closest match is
    // ListPredictions, which returns PestPrediction objects (contain fieldId,
    // riskLevel, geographicRiskFactor, etc.). We map predictions to zones.
    try {
      final request = ListPredictionsRequest(
        fieldId: fieldId,
      );
      final response = await _call('ListPredictions', request);
      final result = ListPredictionsResponse.fromBuffer(response.body);

      return result.predictions.map((prediction) {
        return PestRiskZoneModel(
          id: prediction.id,
          fieldId: prediction.fieldId,
          riskLevel: _mapProtoRiskLevel(prediction.riskLevel),
          pestType: prediction.cropType.isNotEmpty
              ? prediction.cropType
              : prediction.pestSpeciesId,
          polygon: const [], // No polygon data in PestPrediction proto
          alertDate: prediction.hasPredictionDate()
              ? prediction.predictionDate.toDateTime()
              : DateTime.now(),
          description: 'Risk score: ${prediction.riskScore}, '
              'Confidence: ${prediction.confidencePct}%',
        );
      }).toList();
    } on ConnectException catch (e) {
      _log.severe('Failed to fetch pest risk zones: $e');
      rethrow;
    }
  }

  @override
  Future<List<PestAlertModel>> fetchPestAlerts({String? fieldId}) async {
    try {
      final request = ListAlertsRequest(
        fieldId: fieldId,
      );
      final response = await _call('ListAlerts', request);
      final result = ListAlertsResponse.fromBuffer(response.body);

      return result.alerts.map(_mapPestAlertToModel).toList();
    } on ConnectException catch (e) {
      _log.severe('Failed to fetch pest alerts: $e');
      rethrow;
    }
  }

  @override
  Future<PestAlertModel> fetchPestAlertById(String alertId) async {
    // NOTE: The proto has no single GetAlert RPC. We use ListAlerts and filter,
    // or we can use ListAlerts. There is no direct GetAlert by ID in the proto.
    // TODO: Add GetAlert RPC to the proto definition.
    // For now, list all alerts and find the matching one.
    try {
      final request = ListAlertsRequest();
      final response = await _call('ListAlerts', request);
      final result = ListAlertsResponse.fromBuffer(response.body);

      final alert = result.alerts.firstWhere(
        (a) => a.id == alertId,
        orElse: () => throw ConnectException(
          code: 'not_found',
          message: 'Alert $alertId not found',
        ),
      );
      return _mapPestAlertToModel(alert);
    } on ConnectException catch (e) {
      _log.severe('Failed to fetch pest alert $alertId: $e');
      rethrow;
    }
  }

  @override
  Future<void> markAlertAsRead(String alertId) async {
    try {
      final request = AcknowledgeAlertRequest(id: alertId);
      await _call('AcknowledgeAlert', request);
    } on ConnectException catch (e) {
      _log.severe('Failed to mark alert $alertId as read: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static PestAlertModel _mapPestAlertToModel(PestAlert alert) {
    return PestAlertModel(
      id: alert.id,
      zoneId: alert.predictionId,
      fieldId: alert.fieldId,
      pestType: alert.pestSpeciesId,
      riskLevel: _mapProtoRiskLevel(alert.riskLevel),
      title: alert.title,
      message: alert.message,
      recommendations: const [], // No recommendations field in PestAlert proto
      createdAt: alert.hasCreatedAt()
          ? alert.createdAt.toDateTime()
          : DateTime.now(),
      isRead: alert.status == pest_proto.AlertStatus.ALERT_STATUS_ACKNOWLEDGED,
    );
  }

  static RiskLevel _mapProtoRiskLevel(
      pest_proto.RiskLevel protoLevel) {
    return switch (protoLevel) {
      pest_proto.RiskLevel.RISK_LEVEL_LOW => RiskLevel.low,
      pest_proto.RiskLevel.RISK_LEVEL_MODERATE => RiskLevel.moderate,
      pest_proto.RiskLevel.RISK_LEVEL_HIGH => RiskLevel.high,
      pest_proto.RiskLevel.RISK_LEVEL_CRITICAL => RiskLevel.critical,
      _ => RiskLevel.low,
    };
  }
}
