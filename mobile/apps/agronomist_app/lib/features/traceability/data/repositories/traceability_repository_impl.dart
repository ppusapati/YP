import 'package:flutter_network/flutter_network.dart';
import 'package:logging/logging.dart';

import '../../domain/entities/trace_record_entity.dart';
import '../../domain/repositories/traceability_repository.dart';
import '../datasources/traceability_local_datasource.dart';
import '../datasources/traceability_remote_datasource.dart';
import '../models/trace_record_model.dart';

class TraceabilityRepositoryImpl implements TraceabilityRepository {
  final TraceabilityRemoteDataSource _remoteDataSource;
  final TraceabilityLocalDataSource _localDataSource;
  final ConnectivityService _connectivityService;
  final _log = Logger('TraceabilityRepository');

  TraceabilityRepositoryImpl({
    required TraceabilityRemoteDataSource remoteDataSource,
    required TraceabilityLocalDataSource localDataSource,
    required ConnectivityService connectivityService,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _connectivityService = connectivityService;

  bool get _isOnline =>
      _connectivityService.currentStatus == ConnectivityStatus.online;

  @override
  Future<List<TraceRecordEntity>> getTraceRecords({
    String? fieldId,
    String? batchNumber,
  }) async {
    if (_isOnline) {
      try {
        final remote = await _remoteDataSource.getTraceRecords(
          fieldId: fieldId,
          batchNumber: batchNumber,
        );
        await _localDataSource.cacheTraceRecords(remote);
        return remote.map((m) => m.toEntity()).toList();
      } catch (e) {
        _log.warning('Remote fetch trace records failed, falling back to cache: $e');
      }
    }
    final cached = await _localDataSource.getTraceRecords();
    var results = cached.map((m) => m.toEntity()).toList();
    if (fieldId != null) {
      results = results.where((r) => r.fieldId == fieldId).toList();
    }
    if (batchNumber != null) {
      results = results.where((r) => r.batchNumber == batchNumber).toList();
    }
    return results;
  }

  @override
  Future<TraceRecordEntity> getTraceRecordById(String id) async {
    if (_isOnline) {
      try {
        final remote = await _remoteDataSource.getTraceRecordById(id);
        await _localDataSource.cacheTraceRecord(remote);
        return remote.toEntity();
      } catch (e) {
        _log.warning('Remote fetch trace record $id failed: $e');
      }
    }
    final cached = await _localDataSource.getTraceRecordById(id);
    if (cached == null) {
      throw Exception('Trace record $id not found in cache');
    }
    return cached.toEntity();
  }

  @override
  Future<TraceRecordEntity> createTraceRecord(TraceRecordEntity record) async {
    final model = TraceRecordModel.fromEntity(record);
    final created = await _remoteDataSource.createTraceRecord(model);
    await _localDataSource.cacheTraceRecord(created);
    return created.toEntity();
  }
}
