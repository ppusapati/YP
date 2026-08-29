import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/soil_analysis_model.dart';

abstract class SoilAnalysisLocalDataSource {
  Future<List<SoilAnalysisModel>> getSoilAnalyses(String fieldId);
  Future<void> cacheSoilAnalyses(
      String fieldId, List<SoilAnalysisModel> analyses);
  Future<void> clear();
}

class SoilAnalysisLocalDataSourceImpl implements SoilAnalysisLocalDataSource {
  static const _cachePrefix = 'cached_soil_';
  final SharedPreferences _prefs;
  final _log = Logger('SoilAnalysisLocalDataSource');

  SoilAnalysisLocalDataSourceImpl(this._prefs);

  @override
  Future<List<SoilAnalysisModel>> getSoilAnalyses(String fieldId) async {
    final raw = _prefs.getString('$_cachePrefix$fieldId');
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => SoilAnalysisModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _log.warning('Failed to decode cached soil analyses: $e');
      return [];
    }
  }

  @override
  Future<void> cacheSoilAnalyses(
      String fieldId, List<SoilAnalysisModel> analyses) async {
    final raw = jsonEncode(analyses.map((e) => e.toJson()).toList());
    await _prefs.setString('$_cachePrefix$fieldId', raw);
  }

  @override
  Future<void> clear() async {
    final keys =
        _prefs.getKeys().where((k) => k.startsWith(_cachePrefix)).toList();
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }
}
