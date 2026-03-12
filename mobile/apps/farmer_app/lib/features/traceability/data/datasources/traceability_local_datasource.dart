import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/produce_record_model.dart';

/// Local cache for traceability records.
abstract class TraceabilityLocalDataSource {
  Future<List<ProduceRecordModel>> getCachedFarmHistory(String farmId);
  Future<void> cacheFarmHistory(
      String farmId, List<ProduceRecordModel> records);
  Future<ProduceRecordModel?> getCachedRecord(String recordId);
  Future<void> cacheRecord(ProduceRecordModel record);
  Future<void> clearCache();
}

class TraceabilityLocalDataSourceImpl implements TraceabilityLocalDataSource {
  TraceabilityLocalDataSourceImpl({
    required SharedPreferences sharedPreferences,
  }) : _prefs = sharedPreferences;

  final SharedPreferences _prefs;
  static final _log = Logger('TraceabilityLocalDataSource');

  static const _historyPrefix = 'traceability_history_';
  static const _recordPrefix = 'traceability_record_';
  static const _cacheDuration = Duration(hours: 4);

  @override
  Future<List<ProduceRecordModel>> getCachedFarmHistory(
    String farmId,
  ) async {
    try {
      final key = '$_historyPrefix$farmId';
      final timeKey = '${key}_time';

      if (!_isCacheValid(timeKey)) return [];

      final jsonString = _prefs.getString(key);
      if (jsonString == null) return [];

      final list = jsonDecode(jsonString) as List<dynamic>;
      return list
          .map((e) =>
              ProduceRecordModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _log.warning('Failed to read cached farm history: $e');
      return [];
    }
  }

  @override
  Future<void> cacheFarmHistory(
    String farmId,
    List<ProduceRecordModel> records,
  ) async {
    try {
      final key = '$_historyPrefix$farmId';
      final jsonString = jsonEncode(records.map((r) => r.toJson()).toList());
      await _prefs.setString(key, jsonString);
      await _prefs.setInt(
          '${key}_time', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      _log.warning('Failed to cache farm history: $e');
    }
  }

  @override
  Future<ProduceRecordModel?> getCachedRecord(String recordId) async {
    try {
      final key = '$_recordPrefix$recordId';
      final timeKey = '${key}_time';

      if (!_isCacheValid(timeKey)) return null;

      final jsonString = _prefs.getString(key);
      if (jsonString == null) return null;

      return ProduceRecordModel.fromJson(
        jsonDecode(jsonString) as Map<String, dynamic>,
      );
    } catch (e) {
      _log.warning('Failed to read cached record: $e');
      return null;
    }
  }

  @override
  Future<void> cacheRecord(ProduceRecordModel record) async {
    try {
      final key = '$_recordPrefix${record.id}';
      await _prefs.setString(key, jsonEncode(record.toJson()));
      await _prefs.setInt(
          '${key}_time', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      _log.warning('Failed to cache record: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_historyPrefix) ||
          key.startsWith(_recordPrefix)) {
        await _prefs.remove(key);
      }
    }
  }

  bool _isCacheValid(String timeKey) {
    final cachedTime = _prefs.getInt(timeKey);
    if (cachedTime == null) return false;
    final cacheDate = DateTime.fromMillisecondsSinceEpoch(cachedTime);
    return DateTime.now().difference(cacheDate) < _cacheDuration;
  }
}
