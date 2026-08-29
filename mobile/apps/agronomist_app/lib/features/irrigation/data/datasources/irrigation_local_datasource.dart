import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/irrigation_model.dart';

abstract class IrrigationLocalDataSource {
  Future<List<IrrigationZoneModel>> getZones(String fieldId);
  Future<void> cacheZones(String fieldId, List<IrrigationZoneModel> zones);
  Future<void> clear();
}

class IrrigationLocalDataSourceImpl implements IrrigationLocalDataSource {
  static const _cachePrefix = 'cached_irrigation_zones_';
  final SharedPreferences _prefs;

  IrrigationLocalDataSourceImpl(this._prefs);

  @override
  Future<List<IrrigationZoneModel>> getZones(String fieldId) async {
    final raw = _prefs.getString('$_cachePrefix$fieldId');
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => IrrigationZoneModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> cacheZones(String fieldId, List<IrrigationZoneModel> zones) async {
    final raw = jsonEncode(zones.map((e) => e.toJson()).toList());
    await _prefs.setString('$_cachePrefix$fieldId', raw);
  }

  @override
  Future<void> clear() async {
    final keys = _prefs.getKeys().where((k) => k.startsWith(_cachePrefix)).toList();
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }
}
