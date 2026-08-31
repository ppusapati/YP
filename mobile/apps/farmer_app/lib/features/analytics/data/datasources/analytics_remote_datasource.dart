import 'dart:convert';

import 'package:flutter_network/flutter_network.dart';
import 'package:logging/logging.dart';

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

  AnalyticsRemoteDataSourceImpl(this._client);

  Future<Map<String, dynamic>> _post(
      String method, Map<String, dynamic> body) async {
    final path = '/agriculture.field.analytics.v1.FieldAnalyticsService/$method';
    _log.fine('POST $path');

    final response = await _client.unary(
      path,
      body: utf8.encoder.convert(jsonEncode(body)),
      headers: {'Content-Type': 'application/json'},
    );

    if (!response.isSuccess) {
      throw ConnectException(
        code: 'internal',
        message: 'AnalyticsService/$method failed',
      );
    }

    return jsonDecode(utf8.decode(response.body)) as Map<String, dynamic>;
  }

  @override
  Future<List<FieldAnalyticsModel>> getFieldAnalyticsList(
      {String? farmId}) async {
    final body = <String, dynamic>{};
    if (farmId != null) body['farm_id'] = farmId;
    final data = await _post('ListFieldAnalytics', body);
    final list = data['field_analytics'] as List<dynamic>? ?? [];
    return list
        .map((e) =>
            FieldAnalyticsModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<FieldAnalyticsModel> getFieldAnalytics(String fieldId) async {
    final data =
        await _post('GetFieldAnalytics', {'field_id': fieldId});
    return FieldAnalyticsModel.fromJson(
        data['field_analytics'] as Map<String, dynamic>);
  }

  @override
  Future<List<SeasonComparisonModel>> getSeasonComparisons(
      String fieldId) async {
    final data =
        await _post('GetSeasonComparisons', {'field_id': fieldId});
    final list = data['season_comparisons'] as List<dynamic>? ?? [];
    return list
        .map((e) =>
            SeasonComparisonModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<RotationScoreModel> getRotationAnalysis(String fieldId) async {
    final data =
        await _post('GetRotationAnalysis', {'field_id': fieldId});
    return RotationScoreModel.fromJson(
        data['rotation_score'] as Map<String, dynamic>);
  }
}
