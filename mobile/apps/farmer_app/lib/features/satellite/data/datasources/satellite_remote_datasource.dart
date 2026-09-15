import 'package:flutter_network/flutter_network.dart';
import 'package:flutter_proto/src/generated/satellite.pb.dart';
import 'package:logging/logging.dart';
import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart'
    as timestamp_pb;

import '../../domain/entities/satellite_entity.dart';
import '../models/ndvi_data_model.dart';
import '../models/satellite_tile_model.dart';

/// Remote data source for satellite monitoring using ConnectRPC.
abstract class SatelliteRemoteDataSource {
  Future<List<SatelliteTileModel>> getSatelliteTiles({
    required String fieldId,
    SatelliteLayerType? layerType,
    DateTime? from,
    DateTime? to,
  });

  Future<List<NdviDataModel>> getNdviHistory({
    required String fieldId,
    required DateTime from,
    required DateTime to,
  });

  Future<Map<String, dynamic>> getCropHealth({required String fieldId});
  Future<List<Map<String, dynamic>>> getCropHealthByFarm({
    required String farmId,
    required List<String> fieldIds,
  });
}

/// ConnectRPC-based implementation of [SatelliteRemoteDataSource].
class SatelliteRemoteDataSourceImpl implements SatelliteRemoteDataSource {
  final ConnectClient _client;
  final _log = Logger('SatelliteRemoteDataSource');
  static const _basePath = '/agriculture.satellite.v1.SatelliteService';

  SatelliteRemoteDataSourceImpl({required ConnectClient client})
      : _client = client;

  Future<ConnectResponse> _call(
      String method, $pb.GeneratedMessage request) async {
    final response = await _client.unary(
      '$_basePath/$method',
      body: request.writeToBuffer(),
    );
    if (!response.isSuccess) {
      // Logged as well as thrown: the exception reaches the repository, which
      // falls back to the cache, so without this line a satellite service that
      // is down looks from the app exactly like one with no new imagery.
      _log.warning(
        '$_basePath/$method failed with HTTP ${response.statusCode}',
      );
      throw ConnectException(
        code: 'internal',
        message: '$_basePath/$method failed',
        statusCode: response.statusCode,
      );
    }
    return response;
  }

  @override
  Future<List<SatelliteTileModel>> getSatelliteTiles({
    required String fieldId,
    SatelliteLayerType? layerType,
    DateTime? from,
    DateTime? to,
  }) async {
    // The proto has ListImages which returns SatelliteImage objects.
    // We map SatelliteImage to SatelliteTileModel.
    final request = ListImagesRequest(fieldId: fieldId);
    final response = await _call('ListImages', request);
    final result = ListImagesResponse.fromBuffer(response.body);

    return result.images.map((image) {
      return SatelliteTileModel(
        id: image.id,
        fieldId: image.fieldId,
        layerType: layerType ?? SatelliteLayerType.ndvi,
        tileUrl: image.imageUrl,
        captureDate: image.hasAcquisitionDate()
            ? image.acquisitionDate.toDateTime()
            : DateTime.now(),
        cloudCoverPercent: image.cloudCoverPct,
      );
    }).toList();
  }

  @override
  Future<List<NdviDataModel>> getNdviHistory({
    required String fieldId,
    required DateTime from,
    required DateTime to,
  }) async {
    // The proto has GetTemporalAnalysis which returns a TemporalAnalysis with
    // dataPoints (TemporalDataPoint: date, meanValue, minValue, maxValue).
    final request = GetTemporalAnalysisRequest(
      fieldId: fieldId,
      indexType: 'NDVI',
      startDate: _toTimestamp(from),
      endDate: _toTimestamp(to),
    );
    final response = await _call('GetTemporalAnalysis', request);
    final result = GetTemporalAnalysisResponse.fromBuffer(response.body);

    if (!result.hasAnalysis()) return [];

    return result.analysis.dataPoints.map((dp) {
      return NdviDataModel(
        date: dp.hasDate() ? dp.date.toDateTime() : DateTime.now(),
        meanNdvi: dp.meanValue,
        minNdvi: dp.minValue,
        maxNdvi: dp.maxValue,
      );
    }).toList();
  }

  @override
  Future<Map<String, dynamic>> getCropHealth({required String fieldId}) async {
    // The proto has DetectCropStress which is the closest to getCropHealth.
    // It returns a CropStressAlert with stressDetected, stressType,
    // stressSeverity, affectedAreaPct, description, recommendation.
    final request = DetectCropStressRequest(fieldId: fieldId);
    final response = await _call('DetectCropStress', request);
    final result = DetectCropStressResponse.fromBuffer(response.body);

    if (!result.hasAlert()) return {};

    final alert = result.alert;
    return {
      'stress_detected': alert.stressDetected,
      'stress_type': alert.stressType.name,
      'stress_severity': alert.stressSeverity,
      'affected_area_pct': alert.affectedAreaPct,
      'description': alert.description,
      'recommendation': alert.recommendation,
    };
  }

  /// Crop stress alerts for a farm.
  ///
  /// satellite-service's ListAlerts filters by field, not farm — there is no
  /// farm-level listing — so this fans out over the farm's fields. The caller
  /// asked about a farm and gets an answer about a farm; doing it here rather
  /// than making every caller loop is what keeps that true.
  @override
  Future<List<Map<String, dynamic>>> getCropHealthByFarm({
    required String farmId,
    required List<String> fieldIds,
  }) async {
    final alerts = <Map<String, dynamic>>[];
    for (final fieldId in fieldIds) {
      final request = ListAlertsRequest(fieldId: fieldId);
      final response = await _call('ListAlerts', request);
      final result = ListAlertsResponse.fromBuffer(response.body);
      alerts.addAll(result.alerts.map(_alertToMap));
    }
    return alerts;
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static Map<String, dynamic> _alertToMap(CropStressAlert alert) {
    return {
      'id': alert.id,
      'field_id': alert.fieldId,
      'alert_type': alert.stressType.name,
      'severity': alert.stressSeverity,
      'description': alert.description,
      'detected_at': alert.hasDetectedAt()
          ? alert.detectedAt.toDateTime().toIso8601String()
          : '',
    };
  }

  static timestamp_pb.Timestamp _toTimestamp(DateTime dt) {
    return timestamp_pb.Timestamp.fromDateTime(dt);
  }
}
