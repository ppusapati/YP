import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/farm_model.dart';

/// Local data source for farm operations using SharedPreferences.
abstract class FarmLocalDataSource {
  Future<List<FarmModel>> getFarms();
  Future<FarmModel?> getFarmById(String farmId);
  Future<void> cacheFarms(List<FarmModel> farms);
  Future<void> cacheFarm(FarmModel farm);
  Future<void> deleteFarm(String farmId);
  Future<void> clearAll();
}

/// SharedPreferences-based implementation of [FarmLocalDataSource].
class FarmLocalDataSourceImpl implements FarmLocalDataSource {
  static const _cacheKey = 'cached_farms';
  final SharedPreferences _prefs;
  final _log = Logger('FarmLocalDataSource');

  FarmLocalDataSourceImpl(this._prefs);

  List<FarmModel> _readAll() {
    final raw = _prefs.getString(_cacheKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => FarmModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _log.warning('Failed to decode cached farms: $e');
      return [];
    }
  }

  Future<void> _writeAll(List<FarmModel> farms) async {
    final raw = jsonEncode(farms.map((f) => f.toJson()).toList());
    await _prefs.setString(_cacheKey, raw);
  }

  @override
  Future<List<FarmModel>> getFarms() async {
    return _readAll();
  }

  @override
  Future<FarmModel?> getFarmById(String farmId) async {
    final farms = _readAll();
    try {
      return farms.firstWhere((f) => f.id == farmId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> cacheFarms(List<FarmModel> farms) async {
    _log.fine('Caching ${farms.length} farms');
    await _writeAll(farms);
  }

  @override
  Future<void> cacheFarm(FarmModel farm) async {
    final farms = _readAll();
    final index = farms.indexWhere((f) => f.id == farm.id);
    if (index >= 0) {
      farms[index] = farm;
    } else {
      farms.add(farm);
    }
    await _writeAll(farms);
  }

  @override
  Future<void> deleteFarm(String farmId) async {
    final farms = _readAll();
    farms.removeWhere((f) => f.id == farmId);
    await _writeAll(farms);
  }

  @override
  Future<void> clearAll() async {
    await _prefs.remove(_cacheKey);
  }
}
