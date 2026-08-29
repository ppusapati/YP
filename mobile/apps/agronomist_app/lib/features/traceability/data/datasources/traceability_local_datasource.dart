import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/trace_record_model.dart';

abstract class TraceabilityLocalDataSource {
  Future<List<TraceRecordModel>> getTraceRecords();
  Future<TraceRecordModel?> getTraceRecordById(String id);
  Future<void> cacheTraceRecords(List<TraceRecordModel> records);
  Future<void> cacheTraceRecord(TraceRecordModel record);
  Future<void> clearAll();
}

class TraceabilityLocalDataSourceImpl implements TraceabilityLocalDataSource {
  static const _cacheKey = 'cached_trace_records';
  final SharedPreferences _prefs;
  final _log = Logger('TraceabilityLocalDataSource');

  TraceabilityLocalDataSourceImpl(this._prefs);

  List<TraceRecordModel> _readAll() {
    final raw = _prefs.getString(_cacheKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => TraceRecordModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _log.warning('Failed to decode cached trace records: $e');
      return [];
    }
  }

  Future<void> _writeAll(List<TraceRecordModel> records) async {
    final raw = jsonEncode(records.map((r) => r.toJson()).toList());
    await _prefs.setString(_cacheKey, raw);
  }

  @override
  Future<List<TraceRecordModel>> getTraceRecords() async {
    return _readAll();
  }

  @override
  Future<TraceRecordModel?> getTraceRecordById(String id) async {
    final records = _readAll();
    try {
      return records.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> cacheTraceRecords(List<TraceRecordModel> records) async {
    _log.fine('Caching ${records.length} trace records');
    await _writeAll(records);
  }

  @override
  Future<void> cacheTraceRecord(TraceRecordModel record) async {
    final records = _readAll();
    final index = records.indexWhere((r) => r.id == record.id);
    if (index >= 0) {
      records[index] = record;
    } else {
      records.add(record);
    }
    await _writeAll(records);
  }

  @override
  Future<void> clearAll() async {
    await _prefs.remove(_cacheKey);
  }
}
