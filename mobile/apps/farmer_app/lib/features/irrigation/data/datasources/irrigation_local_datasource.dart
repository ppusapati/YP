import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/irrigation_schedule_model.dart';
import '../models/irrigation_zone_model.dart';

abstract class IrrigationLocalDataSource {
  Future<List<IrrigationZoneModel>> getCachedZones(String fieldId);
  Future<void> cacheZones(String fieldId, List<IrrigationZoneModel> zones);
  Future<List<IrrigationScheduleModel>> getCachedSchedules(String zoneId);
  Future<void> cacheSchedules(
      String zoneId, List<IrrigationScheduleModel> schedules);
  Future<void> clearCache();
}

class IrrigationLocalDataSourceImpl implements IrrigationLocalDataSource {
  IrrigationLocalDataSourceImpl({required SharedPreferences sharedPreferences})
      : _prefs = sharedPreferences;

  final SharedPreferences _prefs;

  static const _zonesPrefix = 'irrigation_zones_';
  static const _schedulesPrefix = 'irrigation_schedules_';

  @override
  Future<List<IrrigationZoneModel>> getCachedZones(String fieldId) async {
    final jsonString = _prefs.getString('$_zonesPrefix$fieldId');
    if (jsonString == null) return [];
    final List<dynamic> decoded = json.decode(jsonString);
    return decoded
        .map((e) => IrrigationZoneModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> cacheZones(
      String fieldId, List<IrrigationZoneModel> zones) async {
    final jsonList = zones.map((z) => z.toJson()).toList();
    await _prefs.setString('$_zonesPrefix$fieldId', json.encode(jsonList));
  }

  @override
  Future<List<IrrigationScheduleModel>> getCachedSchedules(
      String zoneId) async {
    final jsonString = _prefs.getString('$_schedulesPrefix$zoneId');
    if (jsonString == null) return [];
    final List<dynamic> decoded = json.decode(jsonString);
    return decoded
        .map(
            (e) => IrrigationScheduleModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> cacheSchedules(
      String zoneId, List<IrrigationScheduleModel> schedules) async {
    final jsonList = schedules.map((s) => s.toJson()).toList();
    await _prefs.setString('$_schedulesPrefix$zoneId', json.encode(jsonList));
  }

  @override
  Future<void> clearCache() async {
    final keys = _prefs.getKeys().where(
        (k) => k.startsWith(_zonesPrefix) || k.startsWith(_schedulesPrefix));
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }
}
