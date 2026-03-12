import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/yield_prediction_model.dart';

abstract class YieldLocalDataSource {
  Future<List<YieldPredictionModel>> getCachedPredictions();
  Future<void> cachePredictions(List<YieldPredictionModel> predictions);
  Future<List<YieldPredictionModel>> getCachedHistory(String fieldId);
  Future<void> cacheHistory(
      String fieldId, List<YieldPredictionModel> history);
  Future<void> clearCache();
}

class YieldLocalDataSourceImpl implements YieldLocalDataSource {
  YieldLocalDataSourceImpl({required SharedPreferences sharedPreferences})
      : _prefs = sharedPreferences;

  final SharedPreferences _prefs;

  static const _predictionsKey = 'yield_predictions';
  static const _historyPrefix = 'yield_history_';

  @override
  Future<List<YieldPredictionModel>> getCachedPredictions() async {
    final jsonString = _prefs.getString(_predictionsKey);
    if (jsonString == null) return [];
    final List<dynamic> decoded = json.decode(jsonString);
    return decoded
        .map((e) =>
            YieldPredictionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> cachePredictions(
      List<YieldPredictionModel> predictions) async {
    final jsonList = predictions.map((p) => p.toJson()).toList();
    await _prefs.setString(_predictionsKey, json.encode(jsonList));
  }

  @override
  Future<List<YieldPredictionModel>> getCachedHistory(String fieldId) async {
    final jsonString = _prefs.getString('$_historyPrefix$fieldId');
    if (jsonString == null) return [];
    final List<dynamic> decoded = json.decode(jsonString);
    return decoded
        .map((e) =>
            YieldPredictionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> cacheHistory(
      String fieldId, List<YieldPredictionModel> history) async {
    final jsonList = history.map((h) => h.toJson()).toList();
    await _prefs.setString('$_historyPrefix$fieldId', json.encode(jsonList));
  }

  @override
  Future<void> clearCache() async {
    await _prefs.remove(_predictionsKey);
    final keys =
        _prefs.getKeys().where((k) => k.startsWith(_historyPrefix));
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }
}
