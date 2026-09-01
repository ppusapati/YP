import 'package:flutter_network/flutter_network.dart';
import 'package:flutter_proto/src/generated/satellite.pb.dart' as satellite_pb;
import 'package:protobuf/protobuf.dart' as $pb;

import '../models/satellite_data_model.dart';

abstract class SatelliteRemoteDataSource {
  Future<List<SatelliteDataModel>> getTilesForField(String fieldId);
  Future<List<StressAlertModel>> getStressAlerts(String farmId);
  Future<Map<String, dynamic>> getFieldSummary(String farmId, String fieldId);
}

class SatelliteRemoteDataSourceImpl implements SatelliteRemoteDataSource {
  final ConnectClient _client;

  static const _basePath = '/agriculture.satellite.v1.SatelliteService';

  SatelliteRemoteDataSourceImpl(this._client);

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
  Future<List<SatelliteDataModel>> getTilesForField(String fieldId) async {
    final request = satellite_pb.ListImagesRequest(fieldId: fieldId);
    final response = await _call('ListImages', request);
    final pbResponse =
        satellite_pb.ListImagesResponse.fromBuffer(response.body);
    return pbResponse.images.map(_imageToModel).toList();
  }

  @override
  Future<List<StressAlertModel>> getStressAlerts(String farmId) async {
    // ListAlertsRequest does not have a farmId field; filtering by farm is
    // not supported in the proto. We send an unfiltered request.
    final request = satellite_pb.ListAlertsRequest();
    final response = await _call('ListAlerts', request);
    final pbResponse =
        satellite_pb.ListAlertsResponse.fromBuffer(response.body);
    return pbResponse.alerts.map(_alertToModel).toList();
  }

  @override
  Future<Map<String, dynamic>> getFieldSummary(
      String farmId, String fieldId) async {
    final request =
        satellite_pb.GetTemporalAnalysisRequest(fieldId: fieldId);
    final response = await _call('GetTemporalAnalysis', request);
    final pbResponse =
        satellite_pb.GetTemporalAnalysisResponse.fromBuffer(response.body);
    final analysis = pbResponse.analysis;
    return {
      'field_id': analysis.fieldId,
      'index_type': analysis.indexType,
      'data_points': analysis.dataPoints.length,
    };
  }

  /// Converts a protobuf [satellite_pb.SatelliteImage] to [SatelliteDataModel].
  static SatelliteDataModel _imageToModel(satellite_pb.SatelliteImage pb) {
    final captureDate = pb.hasAcquisitionDate()
        ? DateTime.fromMillisecondsSinceEpoch(
            pb.acquisitionDate.seconds.toInt() * 1000)
        : DateTime.now();
    return SatelliteDataModel(
      id: pb.id,
      fieldId: pb.fieldId,
      tileUrl: pb.imageUrl,
      captureDate: captureDate,
      indexType: 'ndvi',
    );
  }

  /// Converts a protobuf [satellite_pb.CropStressAlert] to [StressAlertModel].
  static StressAlertModel _alertToModel(satellite_pb.CropStressAlert pb) {
    final detectedAt = pb.hasDetectedAt()
        ? DateTime.fromMillisecondsSinceEpoch(
            pb.detectedAt.seconds.toInt() * 1000)
        : DateTime.now();
    return StressAlertModel(
      id: pb.id,
      farmId: '',
      fieldId: pb.fieldId,
      stressType: pb.stressType.name,
      severity: pb.stressSeverity > 0.7
          ? 'high'
          : pb.stressSeverity > 0.4
              ? 'medium'
              : 'low',
      confidence: pb.stressSeverity,
      affectedArea: pb.affectedAreaPct,
      detectedAt: detectedAt,
    );
  }
}
