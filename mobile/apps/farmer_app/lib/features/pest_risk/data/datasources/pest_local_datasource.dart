import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/pest_risk_model.dart';

/// Local cache for pest risk data, backed by SharedPreferences.
abstract class PestLocalDataSource {
  Future<List<PestRiskZoneModel>> getCachedPestRiskZones();
  Future<void> cachePestRiskZones(List<PestRiskZoneModel> zones);
  Future<List<PestAlertModel>> getCachedPestAlerts();
  Future<void> cachePestAlerts(List<PestAlertModel> alerts);
  Future<void> clearCache();
}

class PestLocalDataSourceImpl implements PestLocalDataSource {
  PestLocalDataSourceImpl({required SharedPreferences sharedPreferences})
      : _prefs = sharedPreferences;

  final SharedPreferences _prefs;
  static final _log = Logger('PestLocalDataSource');

  static const _zonesKey = 'pest_risk_zones_cache';
  static const _alertsKey = 'pest_alerts_cache';
  static const _zonesCacheTimeKey = 'pest_risk_zones_cache_time';
  static const _alertsCacheTimeKey = 'pest_alerts_cache_time';

  /// Cache validity duration.
  static const _cacheDuration = Duration(hours: 1);

  @override
  Future<List<PestRiskZoneModel>> getCachedPestRiskZones() async {
    try {
      if (!_isCacheValid(_zonesCacheTimeKey)) return [];

      final jsonString = _prefs.getString(_zonesKey);
      if (jsonString == null) return [];

      final list = jsonDecode(jsonString) as List<dynamic>;
      return list
          .map((e) => PestRiskZoneModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _log.warning('Failed to read cached pest risk zones: $e');
      return [];
    }
  }

  @override
  Future<void> cachePestRiskZones(List<PestRiskZoneModel> zones) async {
    try {
      final jsonString = jsonEncode(zones.map((z) => z.toJson()).toList());
      await _prefs.setString(_zonesKey, jsonString);
      await _prefs.setInt(
        _zonesCacheTimeKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      _log.warning('Failed to cache pest risk zones: $e');
    }
  }

  @override
  Future<List<PestAlertModel>> getCachedPestAlerts() async {
    try {
      if (!_isCacheValid(_alertsCacheTimeKey)) return [];

      final jsonString = _prefs.getString(_alertsKey);
      if (jsonString == null) return [];

      final list = jsonDecode(jsonString) as List<dynamic>;
      return list
          .map((e) => PestAlertModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _log.warning('Failed to read cached pest alerts: $e');
      return [];
    }
  }

  @override
  Future<void> cachePestAlerts(List<PestAlertModel> alerts) async {
    try {
      final jsonString = jsonEncode(alerts.map((a) => a.toJson()).toList());
      await _prefs.setString(_alertsKey, jsonString);
      await _prefs.setInt(
        _alertsCacheTimeKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      _log.warning('Failed to cache pest alerts: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    await _prefs.remove(_zonesKey);
    await _prefs.remove(_alertsKey);
    await _prefs.remove(_zonesCacheTimeKey);
    await _prefs.remove(_alertsCacheTimeKey);
  }

  bool _isCacheValid(String timeKey) {
    final cachedTime = _prefs.getInt(timeKey);
    if (cachedTime == null) return false;

    final cacheDate = DateTime.fromMillisecondsSinceEpoch(cachedTime);
    return DateTime.now().difference(cacheDate) < _cacheDuration;
  }
}
