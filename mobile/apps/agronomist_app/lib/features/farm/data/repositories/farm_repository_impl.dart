import 'package:flutter_network/flutter_network.dart';
import 'package:logging/logging.dart';

import '../../domain/entities/farm_entity.dart';
import '../../domain/repositories/farm_repository.dart';
import '../datasources/farm_local_datasource.dart';
import '../datasources/farm_remote_datasource.dart';
import '../models/farm_model.dart';

/// Repository implementation with offline-first strategy.
class FarmRepositoryImpl implements FarmRepository {
  final FarmRemoteDataSource _remoteDataSource;
  final FarmLocalDataSource _localDataSource;
  final ConnectivityService _connectivityService;
  final _log = Logger('FarmRepository');

  FarmRepositoryImpl({
    required FarmRemoteDataSource remoteDataSource,
    required FarmLocalDataSource localDataSource,
    required ConnectivityService connectivityService,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _connectivityService = connectivityService;

  bool get _isOnline =>
      _connectivityService.currentStatus == ConnectivityStatus.online;

  @override
  Future<List<FarmEntity>> getFarms() async {
    if (_isOnline) {
      try {
        final remoteFarms = await _remoteDataSource.getFarms();
        await _localDataSource.cacheFarms(remoteFarms);
        return remoteFarms.map((m) => m.toEntity()).toList();
      } catch (e) {
        _log.warning('Remote fetch failed, falling back to cache: $e');
      }
    }
    final cached = await _localDataSource.getFarms();
    return cached.map((m) => m.toEntity()).toList();
  }

  @override
  Future<FarmEntity> getFarmById(String farmId) async {
    if (_isOnline) {
      try {
        final remote = await _remoteDataSource.getFarmById(farmId);
        await _localDataSource.cacheFarm(remote);
        return remote.toEntity();
      } catch (e) {
        _log.warning('Remote fetch failed for farm $farmId: $e');
      }
    }
    final cached = await _localDataSource.getFarmById(farmId);
    if (cached == null) {
      throw Exception('Farm $farmId not found in cache');
    }
    return cached.toEntity();
  }

  @override
  Future<FarmEntity> createFarm(FarmEntity farm) async {
    final model = FarmModel.fromEntity(farm);
    final created = await _remoteDataSource.createFarm(model);
    await _localDataSource.cacheFarm(created);
    return created.toEntity();
  }

  @override
  Future<FarmEntity> updateFarm(FarmEntity farm) async {
    final model = FarmModel.fromEntity(farm);
    final updated = await _remoteDataSource.updateFarm(model);
    await _localDataSource.cacheFarm(updated);
    return updated.toEntity();
  }

  @override
  Future<void> deleteFarm(String farmId) async {
    await _remoteDataSource.deleteFarm(farmId);
    await _localDataSource.deleteFarm(farmId);
  }
}
