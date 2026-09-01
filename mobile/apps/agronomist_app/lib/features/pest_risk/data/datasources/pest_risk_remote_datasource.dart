import 'package:flutter_network/flutter_network.dart';
import 'package:flutter_proto/src/generated/pest.pb.dart' as pest_pb;
import 'package:protobuf/protobuf.dart' as $pb;

import '../models/pest_risk_model.dart';

abstract class PestRiskRemoteDataSource {
  Future<List<PestRiskModel>> getPestRisks(String fieldId);
  Future<List<PestRiskModel>> getPestAlerts();
}

class PestRiskRemoteDataSourceImpl implements PestRiskRemoteDataSource {
  final ConnectClient _client;

  static const _basePath = '/agriculture.pest.v1.PestPredictionService';

  PestRiskRemoteDataSourceImpl(this._client);

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
  Future<List<PestRiskModel>> getPestRisks(String fieldId) async {
    final request = pest_pb.ListPredictionsRequest(fieldId: fieldId);
    final response = await _call('ListPredictions', request);
    final pbResponse =
        pest_pb.ListPredictionsResponse.fromBuffer(response.body);
    return pbResponse.predictions.map(_predictionToModel).toList();
  }

  @override
  Future<List<PestRiskModel>> getPestAlerts() async {
    final request = pest_pb.ListAlertsRequest();
    final response = await _call('ListAlerts', request);
    final pbResponse = pest_pb.ListAlertsResponse.fromBuffer(response.body);
    return pbResponse.alerts.map(_alertToModel).toList();
  }

  /// Converts a protobuf [pest_pb.PestPrediction] to [PestRiskModel].
  static PestRiskModel _predictionToModel(pest_pb.PestPrediction pb) {
    final predictedAt = pb.hasPredictionDate()
        ? DateTime.fromMillisecondsSinceEpoch(
            pb.predictionDate.seconds.toInt() * 1000)
        : DateTime.now();
    return PestRiskModel(
      id: pb.id,
      fieldId: pb.fieldId,
      riskLevel: pb.riskLevel.name,
      pestType: pb.cropType,
      description: '',
      probability: pb.confidencePct / 100.0,
      predictedAt: predictedAt,
    );
  }

  /// Converts a protobuf [pest_pb.PestAlert] to [PestRiskModel].
  static PestRiskModel _alertToModel(pest_pb.PestAlert pb) {
    final createdAt = pb.hasCreatedAt()
        ? DateTime.fromMillisecondsSinceEpoch(
            pb.createdAt.seconds.toInt() * 1000)
        : DateTime.now();
    return PestRiskModel(
      id: pb.id,
      fieldId: pb.fieldId,
      riskLevel: pb.riskLevel.name,
      pestType: pb.pestSpeciesId,
      description: pb.message,
      probability: 0,
      predictedAt: createdAt,
    );
  }
}
