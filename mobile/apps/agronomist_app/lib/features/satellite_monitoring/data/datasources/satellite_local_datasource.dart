import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/satellite_data_model.dart';

abstract class SatelliteLocalDataSource {
  Future<List<StressAlertModel>> getStressAlerts(String farmId);
  Future<void> cacheStressAlerts(String farmId, List<StressAlertModel> alerts);
  Future<void> clear();
}

class SatelliteLocalDataSourceImpl implements SatelliteLocalDataSource {
  static const _cachePrefix = 'cached_stress_alerts_';
  final SharedPreferences _prefs;

  SatelliteLocalDataSourceImpl(this._prefs);

  @override
  Future<List<StressAlertModel>> getStressAlerts(String farmId) async {
    final raw = _prefs.getString('$_cachePrefix$farmId');
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => StressAlertModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> cacheStressAlerts(
      String farmId, List<StressAlertModel> alerts) async {
    final raw = jsonEncode(alerts.map((e) => e.toJson()).toList());
    await _prefs.setString('$_cachePrefix$farmId', raw);
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
