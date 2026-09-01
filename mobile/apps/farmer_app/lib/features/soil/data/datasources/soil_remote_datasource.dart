import 'package:flutter_network/flutter_network.dart';
import 'package:flutter_proto/src/generated/soil.pb.dart' as soil_pb;
import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart'
    as timestamp_pb;

import '../models/soil_analysis_model.dart';

abstract class SoilRemoteDataSource {
  Future<SoilAnalysisModel> getSoilAnalysis(String fieldId);
  Future<List<SoilAnalysisModel>> getSoilHistory(
    String fieldId, {
    DateTime? from,
    DateTime? to,
  });
  Future<List<SoilAnalysisModel>> getAllFieldAnalyses();
}

class SoilRemoteDataSourceImpl implements SoilRemoteDataSource {
  const SoilRemoteDataSourceImpl(this._client);

  final ConnectClient _client;

  static const _basePath = '/agriculture.soil.v1.SoilService';

  Future<ConnectResponse> _call(
    String method,
    $pb.GeneratedMessage request,
  ) async {
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
  Future<SoilAnalysisModel> getSoilAnalysis(String fieldId) async {
    // TODO: GetSoilAnalysis RPC does not exist in the soil proto.
    // Using ListSoilAnalyses filtered by fieldId and taking the first result.
    final request = soil_pb.ListSoilAnalysesRequest()..fieldId = fieldId;

    final response = await _call('ListSoilAnalyses', request);

    final pbResponse =
        soil_pb.ListSoilAnalysesResponse.fromBuffer(response.body);
    if (pbResponse.analyses.isEmpty) {
      throw const ConnectException(
        code: 'not_found',
        message: 'Soil analysis not found',
      );
    }
    return _analysisFromPb(pbResponse.analyses.first);
  }

  @override
  Future<List<SoilAnalysisModel>> getSoilHistory(
    String fieldId, {
    DateTime? from,
    DateTime? to,
  }) async {
    // TODO: GetSoilHistory RPC does not exist in the soil proto.
    // Using ListSoilAnalyses filtered by fieldId. Date range filtering
    // is not supported by the proto; results are returned unfiltered.
    final request = soil_pb.ListSoilAnalysesRequest()..fieldId = fieldId;

    final response = await _call('ListSoilAnalyses', request);

    final pbResponse =
        soil_pb.ListSoilAnalysesResponse.fromBuffer(response.body);
    return pbResponse.analyses.map(_analysisFromPb).toList();
  }

  @override
  Future<List<SoilAnalysisModel>> getAllFieldAnalyses() async {
    // TODO: ListFieldAnalyses RPC does not exist in the soil proto.
    // Using ListSoilAnalyses with no filters to return all analyses.
    final request = soil_pb.ListSoilAnalysesRequest();

    final response = await _call('ListSoilAnalyses', request);

    final pbResponse =
        soil_pb.ListSoilAnalysesResponse.fromBuffer(response.body);
    return pbResponse.analyses.map(_analysisFromPb).toList();
  }

  // ---------------------------------------------------------------------------
  // Protobuf-to-model helpers
  // ---------------------------------------------------------------------------

  static SoilAnalysisModel _analysisFromPb(soil_pb.SoilAnalysis pb) {
    return SoilAnalysisModel(
      id: pb.id,
      fieldId: pb.fieldId,
      pH: pb.soilHealthScore, // proto has soilHealthScore, not direct pH
      organicCarbon: 0, // not available in SoilAnalysis pb
      nitrogen: 0, // not available in SoilAnalysis pb
      phosphorus: 0, // not available in SoilAnalysis pb
      potassium: 0, // not available in SoilAnalysis pb
      texture: _mapSoilTexture(pb.healthCategory),
      analysisDate: pb.hasAnalyzedAt()
          ? _timestampToDateTime(pb.analyzedAt)
          : DateTime.now(),
    );
  }

  // ---------------------------------------------------------------------------
  // Enum mapping helpers
  // ---------------------------------------------------------------------------

  static SoilTexture _mapSoilTexture(soil_pb.HealthCategory pbCategory) {
    // SoilAnalysis pb does not carry texture directly; best-effort default.
    return SoilTexture.loamy;
  }

  // ---------------------------------------------------------------------------
  // Timestamp helpers
  // ---------------------------------------------------------------------------

  static DateTime _timestampToDateTime(timestamp_pb.Timestamp ts) {
    return DateTime.fromMillisecondsSinceEpoch(
      ts.seconds.toInt() * 1000 + ts.nanos ~/ 1000000,
    );
  }
}
