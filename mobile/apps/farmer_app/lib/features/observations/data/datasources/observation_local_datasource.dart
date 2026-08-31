import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/observation_model.dart';

/// Local cache for field observations.
abstract class ObservationLocalDataSource {
  Future<List<ObservationModel>> getCachedObservations();
  Future<void> cacheObservations(List<ObservationModel> observations);
  Future<void> cacheObservation(ObservationModel observation);
  Future<void> removeObservation(String observationId);
  Future<void> clearCache();
}

class ObservationLocalDataSourceImpl implements ObservationLocalDataSource {
  ObservationLocalDataSourceImpl({
    required SharedPreferences sharedPreferences,
  }) : _prefs = sharedPreferences;

  final SharedPreferences _prefs;
  static final _log = Logger('ObservationLocalDataSource');

  static const _key = 'field_observations_cache';
  static const _cacheTimeKey = 'field_observations_cache_time';
  static const _cacheDuration = Duration(hours: 2);

  @override
  Future<List<ObservationModel>> getCachedObservations() async {
    try {
      if (!_isCacheValid()) return [];
      final jsonString = _prefs.getString(_key);
      if (jsonString == null) return [];

      final list = jsonDecode(jsonString) as List<dynamic>;
      return list
          .map((e) => ObservationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _log.warning('Failed to read cached observations: $e');
      return [];
    }
  }

  @override
  Future<void> cacheObservations(List<ObservationModel> observations) async {
    try {
      final jsonString =
          jsonEncode(observations.map((o) => o.toJson()).toList());
      await _prefs.setString(_key, jsonString);
      await _prefs.setInt(
          _cacheTimeKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      _log.warning('Failed to cache observations: $e');
    }
  }

  @override
  Future<void> cacheObservation(ObservationModel observation) async {
    final observations = await getCachedObservations();
    final index = observations.indexWhere((o) => o.id == observation.id);
    if (index >= 0) {
      observations[index] = observation;
    } else {
      observations.insert(0, observation);
    }
    await cacheObservations(observations);
  }

  @override
  Future<void> removeObservation(String observationId) async {
    final observations = await getCachedObservations();
    observations.removeWhere((o) => o.id == observationId);
    await cacheObservations(observations);
  }

  @override
  Future<void> clearCache() async {
    await _prefs.remove(_key);
    await _prefs.remove(_cacheTimeKey);
  }

  bool _isCacheValid() {
    final cachedTime = _prefs.getInt(_cacheTimeKey);
    if (cachedTime == null) return false;
    final cacheDate = DateTime.fromMillisecondsSinceEpoch(cachedTime);
    return DateTime.now().difference(cacheDate) < _cacheDuration;
  }
}
