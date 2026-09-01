import 'package:flutter_network/flutter_network.dart';
import 'package:flutter_proto/src/generated/soil.pb.dart' as soil_pb;
import 'package:protobuf/protobuf.dart' as $pb;

import '../models/soil_analysis_model.dart';

abstract class SoilAnalysisRemoteDataSource {
  Future<List<SoilAnalysisModel>> getSoilAnalyses(String fieldId);
  Future<SoilAnalysisModel> createSoilAnalysis(SoilAnalysisModel analysis);
}

class SoilAnalysisRemoteDataSourceImpl implements SoilAnalysisRemoteDataSource {
  final ConnectClient _client;

  static const _basePath = '/agriculture.soil.v1.SoilService';

  SoilAnalysisRemoteDataSourceImpl(this._client);

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
  Future<List<SoilAnalysisModel>> getSoilAnalyses(String fieldId) async {
    final request = soil_pb.ListSoilAnalysesRequest(fieldId: fieldId);
    final response = await _call('ListSoilAnalyses', request);
    final pbResponse =
        soil_pb.ListSoilAnalysesResponse.fromBuffer(response.body);
    return pbResponse.analyses.map(_analysisFromProto).toList();
  }

  @override
  Future<SoilAnalysisModel> createSoilAnalysis(
      SoilAnalysisModel analysis) async {
    // The proto uses AnalyzeSoil which takes a sampleId, not a full analysis
    // object. We pass the field-level identifier via sampleId.
    final request = soil_pb.AnalyzeSoilRequest(
      sampleId: analysis.id,
    );
    final response = await _call('AnalyzeSoil', request);
    final pbResponse = soil_pb.AnalyzeSoilResponse.fromBuffer(response.body);
    return _analysisFromProto(pbResponse.analysis);
  }

  /// Converts a protobuf [soil_pb.SoilAnalysis] to [SoilAnalysisModel].
  static SoilAnalysisModel _analysisFromProto(soil_pb.SoilAnalysis pb) {
    final analyzedAt = pb.hasAnalyzedAt()
        ? DateTime.fromMillisecondsSinceEpoch(
            pb.analyzedAt.seconds.toInt() * 1000)
        : DateTime.now();
    return SoilAnalysisModel(
      id: pb.id,
      fieldId: pb.fieldId,
      pH: 0,
      nitrogen: 0,
      phosphorus: 0,
      potassium: 0,
      organicMatter: 0,
      healthScore: pb.soilHealthScore,
      sampledAt: analyzedAt,
    );
  }
}
