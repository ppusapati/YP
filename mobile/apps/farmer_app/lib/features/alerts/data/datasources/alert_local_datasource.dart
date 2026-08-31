import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/alert_model.dart';

abstract class AlertLocalDataSource {
  Future<List<AlertModel>> getCachedAlerts();
  Future<void> cacheAlerts(List<AlertModel> alerts);
  Future<void> markAlertRead(String alertId);
  Future<void> markAllAlertsRead();
  Future<int> getUnreadCount();
  Future<void> clearCache();
}

class AlertLocalDataSourceImpl implements AlertLocalDataSource {
  const AlertLocalDataSourceImpl(this._prefs);

  final SharedPreferences _prefs;

  static const _cachedAlertsKey = 'cached_alerts';

  @override
  Future<List<AlertModel>> getCachedAlerts() async {
    final jsonString = _prefs.getString(_cachedAlertsKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
    return jsonList
        .map((e) => AlertModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> cacheAlerts(List<AlertModel> alerts) async {
    final jsonList = alerts.map((a) => a.toJson()).toList();
    await _prefs.setString(_cachedAlertsKey, jsonEncode(jsonList));
  }

  @override
  Future<void> markAlertRead(String alertId) async {
    final alerts = await getCachedAlerts();
    final updated = alerts.map((alert) {
      if (alert.id == alertId) {
        return AlertModel.fromEntity(alert.copyWith(read: true));
      }
      return alert;
    }).toList();
    await cacheAlerts(updated);
  }

  @override
  Future<void> markAllAlertsRead() async {
    final alerts = await getCachedAlerts();
    final updated = alerts
        .map((alert) => AlertModel.fromEntity(alert.copyWith(read: true)))
        .toList();
    await cacheAlerts(updated);
  }

  @override
  Future<int> getUnreadCount() async {
    final alerts = await getCachedAlerts();
    return alerts.where((a) => !a.read).length;
  }

  @override
  Future<void> clearCache() async {
    await _prefs.remove(_cachedAlertsKey);
  }
}
