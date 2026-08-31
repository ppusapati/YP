import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/sensor_model.dart';
import '../models/sensor_reading_model.dart';

abstract class SensorLocalDataSource {
  Future<List<SensorModel>> getCachedSensors();
  Future<void> cacheSensors(List<SensorModel> sensors);
  Future<List<SensorReadingModel>> getCachedReadings(String sensorId);
  Future<void> cacheReadings(
    String sensorId,
    List<SensorReadingModel> readings,
  );
  Future<void> clearCache();
}

class SensorLocalDataSourceImpl implements SensorLocalDataSource {
  SensorLocalDataSourceImpl({required SharedPreferences sharedPreferences})
      : _prefs = sharedPreferences;

  final SharedPreferences _prefs;

  static const String _sensorsKey = 'cached_sensors';
  static const String _readingsKeyPrefix = 'cached_readings_';

  @override
  Future<List<SensorModel>> getCachedSensors() async {
    final jsonString = _prefs.getString(_sensorsKey);
    if (jsonString == null) return [];
    final List<dynamic> decoded = json.decode(jsonString);
    return decoded
        .map((e) => SensorModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> cacheSensors(List<SensorModel> sensors) async {
    final jsonList = sensors.map((s) => s.toJson()).toList();
    await _prefs.setString(_sensorsKey, json.encode(jsonList));
  }

  @override
  Future<List<SensorReadingModel>> getCachedReadings(String sensorId) async {
    final jsonString = _prefs.getString('$_readingsKeyPrefix$sensorId');
    if (jsonString == null) return [];
    final List<dynamic> decoded = json.decode(jsonString);
    return decoded
        .map((e) => SensorReadingModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> cacheReadings(
    String sensorId,
    List<SensorReadingModel> readings,
  ) async {
    final jsonList = readings.map((r) => r.toJson()).toList();
    await _prefs.setString(
      '$_readingsKeyPrefix$sensorId',
      json.encode(jsonList),
    );
  }

  @override
  Future<void> clearCache() async {
    final keys =
        _prefs.getKeys().where((k) => k.startsWith(_readingsKeyPrefix));
    for (final key in keys) {
      await _prefs.remove(key);
    }
    await _prefs.remove(_sensorsKey);
  }
}
