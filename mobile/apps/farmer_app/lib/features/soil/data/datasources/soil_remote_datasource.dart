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

  /// Soil analyses for a field, within a date range.
  ///
  /// The `from` and `to` arguments used to be accepted and then ignored, so a
  /// caller asking for this season's samples got every sample ever taken and a
  /// trend chart drawn over the wrong window. The proto's ListSoilAnalyses has
  /// no date filter, so the range is applied here instead — which is honest
  /// about the cost: the server still sends the whole history and this drops
  /// what falls outside. For soil samples, which are taken a handful of times a
  /// season, that is a page of rows rather than a problem; if this ever covers
  /// a high-frequency series, the filter belongs in the proto.
  @override
  Future<List<SoilAnalysisModel>> getSoilHistory(
    String fieldId, {
    DateTime? from,
    DateTime? to,
  }) async {
    final request = soil_pb.ListSoilAnalysesRequest()..fieldId = fieldId;

    final response = await _call('ListSoilAnalyses', request);

    final pbResponse =
        soil_pb.ListSoilAnalysesResponse.fromBuffer(response.body);
    final analyses = pbResponse.analyses.map(_analysisFromPb);

    if (from == null && to == null) {
      return analyses.toList();
    }
    // Inclusive at both ends: a caller asking for a season names its first and
    // last day, and a sample taken on either of them belongs to it.
    return analyses.where((a) {
      final at = a.analysisDate;
      if (from != null && at.isBefore(from)) return false;
      if (to != null && at.isAfter(to)) return false;
      return true;
    }).toList();
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
      pH: pb.pH,
      organicCarbon: pb.organicMatterPct,
      nitrogen: pb.nitrogenPpm,
      phosphorus: pb.phosphorusPpm,
      potassium: pb.potassiumPpm,
      texture: _mapSoilTexture(pb.texture),
      analysisDate: pb.hasAnalyzedAt()
          ? _timestampToDateTime(pb.analyzedAt)
          : DateTime.now(),
    );
  }

  // ---------------------------------------------------------------------------
  // Enum mapping helpers
  // ---------------------------------------------------------------------------

  static SoilTexture _mapSoilTexture(soil_pb.SoilTexture pbTexture) {
    return switch (pbTexture) {
      soil_pb.SoilTexture.SOIL_TEXTURE_SANDY => SoilTexture.sandy,
      soil_pb.SoilTexture.SOIL_TEXTURE_LOAMY => SoilTexture.loamy,
      soil_pb.SoilTexture.SOIL_TEXTURE_CLAY => SoilTexture.clay,
      soil_pb.SoilTexture.SOIL_TEXTURE_SILT => SoilTexture.silt,
      soil_pb.SoilTexture.SOIL_TEXTURE_PEAT => SoilTexture.peat,
      soil_pb.SoilTexture.SOIL_TEXTURE_CHALK => SoilTexture.chalk,
      _ => SoilTexture.loamy,
    };
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
