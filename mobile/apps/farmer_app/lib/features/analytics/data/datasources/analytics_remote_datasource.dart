import 'package:flutter_network/flutter_network.dart';
import 'package:flutter_proto/src/generated/field_analytics.pb.dart' as fa_pb;
import 'package:logging/logging.dart';
import 'package:protobuf/protobuf.dart' as $pb;

import '../models/field_analytics_model.dart';

/// Remote data source for historical analytics operations.
abstract class AnalyticsRemoteDataSource {
  Future<List<FieldAnalyticsModel>> getFieldAnalyticsList({String? farmId});
  Future<FieldAnalyticsModel> getFieldAnalytics(String fieldId);
  Future<List<SeasonComparisonModel>> getSeasonComparisons(String fieldId);
  Future<RotationScoreModel> getRotationAnalysis(String fieldId);
}

class AnalyticsRemoteDataSourceImpl implements AnalyticsRemoteDataSource {
  final ConnectClient _client;
  final _log = Logger('AnalyticsRemoteDataSource');

  static const _basePath = '/agriculture.analytics.v1.FieldAnalyticsService';

  AnalyticsRemoteDataSourceImpl(this._client);

  Future<ConnectResponse> _call(
      String basePath, String method, $pb.GeneratedMessage request) async {
    _log.fine('POST $basePath/$method');
    final response = await _client.unary(
      '$basePath/$method',
      body: request.writeToBuffer(),
    );
    if (!response.isSuccess) {
      throw ConnectException(
        code: 'internal',
        message: '$basePath/$method failed',
        statusCode: response.statusCode,
      );
    }
    return response;
  }

  @override
  Future<List<FieldAnalyticsModel>> getFieldAnalyticsList(
      {String? farmId}) async {
    final request = fa_pb.ListFieldAnalyticsRequest(
      farmId: farmId,
    );
    final response = await _call(_basePath, 'ListFieldAnalytics', request);
    final result =
        fa_pb.ListFieldAnalyticsResponse.fromBuffer(response.body);
    return result.summaries.map(_fieldAnalyticsFromSummary).toList();
  }

  @override
  Future<FieldAnalyticsModel> getFieldAnalytics(String fieldId) async {
    final request = fa_pb.GetFieldAnalyticsRequest(fieldId: fieldId);
    final response = await _call(_basePath, 'GetFieldAnalytics', request);
    final result =
        fa_pb.GetFieldAnalyticsResponse.fromBuffer(response.body);
    return _fieldAnalyticsFromDetail(result);
  }

  @override
  Future<List<SeasonComparisonModel>> getSeasonComparisons(
      String fieldId) async {
    final request = fa_pb.GetSeasonComparisonsRequest(fieldId: fieldId);
    final response = await _call(_basePath, 'GetSeasonComparisons', request);
    final result =
        fa_pb.GetSeasonComparisonsResponse.fromBuffer(response.body);
    return result.comparisons.map(_seasonComparisonFromPb).toList();
  }

  @override
  Future<RotationScoreModel> getRotationAnalysis(String fieldId) async {
    final request = fa_pb.GetRotationAnalysisRequest(fieldId: fieldId);
    final response = await _call(_basePath, 'GetRotationAnalysis', request);
    final result =
        fa_pb.GetRotationAnalysisResponse.fromBuffer(response.body);
    return _rotationScoreFromPb(result.analysis);
  }

  // ---------------------------------------------------------------------------
  // Proto-to-model helpers
  // ---------------------------------------------------------------------------

  static FieldAnalyticsModel _fieldAnalyticsFromSummary(
      fa_pb.FieldAnalyticsSummary pb) {
    return FieldAnalyticsModel(
      fieldId: pb.fieldId,
      fieldName: pb.fieldName,
      meanYield: pb.meanYield,
      peakYield: pb.peakYield,
      yieldTrend: pb.yieldTrend,
      avgStressDays: pb.avgStressDays,
      avgNdvi: pb.avgNdvi,
      seasonsAnalyzed: pb.seasonsAnalyzed,
    );
  }

  static FieldAnalyticsModel _fieldAnalyticsFromDetail(
      fa_pb.GetFieldAnalyticsResponse pb) {
    final summary = pb.summary;
    return FieldAnalyticsModel(
      fieldId: summary.fieldId,
      fieldName: summary.fieldName,
      meanYield: summary.meanYield,
      peakYield: summary.peakYield,
      yieldTrend: summary.yieldTrend,
      avgStressDays: summary.avgStressDays,
      avgNdvi: summary.avgNdvi,
      seasonsAnalyzed: summary.seasonsAnalyzed,
      yieldTrends: pb.yieldTrends.map(_yieldTrendFromPb).toList(),
    );
  }

  static YieldTrendModel _yieldTrendFromPb(fa_pb.YieldTrendPoint pb) {
    return YieldTrendModel(
      season: pb.season,
      crop: pb.crop,
      yieldValue: pb.yieldValue,
      ndvi: pb.hasNdvi() ? pb.ndvi : null,
    );
  }

  static SeasonComparisonModel _seasonComparisonFromPb(
      fa_pb.SeasonComparison pb) {
    return SeasonComparisonModel(
      season: pb.season,
      crop: pb.crop,
      yieldValue: pb.yieldValue,
      yieldVsMeanPct: pb.yieldVsMeanPct,
      stressDays: pb.stressDays,
      stressVsMeanPct: pb.stressVsMeanPct,
      ndviPeak: pb.ndviPeak,
      ndviVsMeanPct: pb.ndviVsMeanPct,
      notableEvents: List<String>.from(pb.notableEvents),
    );
  }

  static RotationScoreModel _rotationScoreFromPb(
      fa_pb.RotationAnalysis pb) {
    return RotationScoreModel(
      effectivenessScore: pb.effectivenessScore,
      diversityIndex: pb.diversityIndex,
      rotationLength: pb.rotationLength,
      soilHealthImpact: pb.soilHealthImpact,
      rotationPattern: List<String>.from(pb.rotationPattern),
      recommendations: List<String>.from(pb.recommendations),
    );
  }
}
