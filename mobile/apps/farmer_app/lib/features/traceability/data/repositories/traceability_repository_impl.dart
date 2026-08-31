import 'package:flutter_network/flutter_network.dart';
import 'package:logging/logging.dart';

import '../../domain/entities/produce_record_entity.dart';
import '../../domain/repositories/traceability_repository.dart';
import '../datasources/traceability_local_datasource.dart';
import '../datasources/traceability_remote_datasource.dart';

/// Concrete [TraceabilityRepository] with remote-first, local-fallback strategy.
class TraceabilityRepositoryImpl implements TraceabilityRepository {
  TraceabilityRepositoryImpl({
    required TraceabilityRemoteDataSource remoteDataSource,
    required TraceabilityLocalDataSource localDataSource,
  })  : _remote = remoteDataSource,
        _local = localDataSource;

  final TraceabilityRemoteDataSource _remote;
  final TraceabilityLocalDataSource _local;
  static final _log = Logger('TraceabilityRepositoryImpl');

  @override
  Future<ProduceRecord> scanQrCode(String qrData) async {
    final record = await _remote.scanQrCode(qrData);
    await _local.cacheRecord(record);
    return record;
  }

  @override
  Future<ProduceRecord> getProduceRecord(String recordId) async {
    try {
      final record = await _remote.fetchProduceRecord(recordId);
      await _local.cacheRecord(record);
      return record;
    } on ConnectException catch (e) {
      _log.warning('Remote fetch failed, checking cache: $e');
      final cached = await _local.getCachedRecord(recordId);
      if (cached != null) return cached;
      rethrow;
    }
  }

  @override
  Future<List<ProduceRecord>> getFarmHistory(String farmId) async {
    try {
      final records = await _remote.fetchFarmHistory(farmId);
      await _local.cacheFarmHistory(farmId, records);
      return records;
    } on ConnectException catch (e) {
      _log.warning('Remote fetch failed, using cache: $e');
      return _local.getCachedFarmHistory(farmId);
    }
  }
}
