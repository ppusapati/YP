import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/soil_analysis_model.dart';

abstract class SoilLocalDataSource {
  Future<SoilAnalysisModel?> getCachedAnalysis(String fieldId);
  Future<void> cacheAnalysis(SoilAnalysisModel analysis);
  Future<List<SoilAnalysisModel>> getCachedHistory(String fieldId);
  Future<void> cacheHistory(String fieldId, List<SoilAnalysisModel> history);
  Future<void> clearCache();
}

class SoilLocalDataSourceImpl implements SoilLocalDataSource {
  SoilLocalDataSourceImpl({required SharedPreferences sharedPreferences})
      : _prefs = sharedPreferences;

  final SharedPreferences _prefs;

  static const _analysisPrefix = 'soil_analysis_';
  static const _historyPrefix = 'soil_history_';

  @override
  Future<SoilAnalysisModel?> getCachedAnalysis(String fieldId) async {
    final jsonString = _prefs.getString('$_analysisPrefix$fieldId');
    if (jsonString == null) return null;
    return SoilAnalysisModel.fromJson(
      json.decode(jsonString) as Map<String, dynamic>,
    );
  }

  @override
  Future<void> cacheAnalysis(SoilAnalysisModel analysis) async {
    await _prefs.setString(
      '$_analysisPrefix${analysis.fieldId}',
      json.encode(analysis.toJson()),
    );
  }

  @override
  Future<List<SoilAnalysisModel>> getCachedHistory(String fieldId) async {
    final jsonString = _prefs.getString('$_historyPrefix$fieldId');
    if (jsonString == null) return [];
    final List<dynamic> decoded = json.decode(jsonString);
    return decoded
        .map((e) => SoilAnalysisModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> cacheHistory(
      String fieldId, List<SoilAnalysisModel> history) async {
    final jsonList = history.map((a) => a.toJson()).toList();
    await _prefs.setString('$_historyPrefix$fieldId', json.encode(jsonList));
  }

  @override
  Future<void> clearCache() async {
    final keys = _prefs.getKeys().where(
        (k) => k.startsWith(_analysisPrefix) || k.startsWith(_historyPrefix));
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }
}
