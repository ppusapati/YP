import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logging/logging.dart';

import '../../domain/entities/farm_entity.dart';
import '../../domain/entities/field_entity.dart';
import '../../domain/repositories/farm_repository.dart';
import '../datasources/farm_local_datasource.dart';
import '../datasources/farm_remote_datasource.dart';
import '../models/farm_model.dart';
import '../models/field_model.dart';

/// Repository implementation that fetches from ConnectRPC, caches in Drift,
/// and serves from cache when offline.
class FarmRepositoryImpl implements FarmRepository {
  FarmRepositoryImpl({
    required FarmRemoteDataSource remoteDataSource,
    required FarmLocalDataSource localDataSource,
    required Connectivity connectivity,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _connectivity = connectivity;

  final FarmRemoteDataSource _remoteDataSource;
  final FarmLocalDataSource _localDataSource;
  final Connectivity _connectivity;
  final _log = Logger('FarmRepository');

  Future<bool> get _isOnline async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  @override
  Future<List<FarmEntity>> getFarms(String userId) async {
    if (await _isOnline) {
      try {
        final remoteFarms = await _remoteDataSource.getFarms(userId);
        await _localDataSource.cacheFarms(remoteFarms);
        return remoteFarms.map((m) => m.toEntity()).toList();
      } catch (e) {
        _log.warning('Remote fetch failed, falling back to cache: $e');
        return _getCachedFarms(userId);
      }
    }
    return _getCachedFarms(userId);
  }

  Future<List<FarmEntity>> _getCachedFarms(String userId) async {
    final cached = await _localDataSource.getFarms(userId);
    return cached.map((m) => m.toEntity()).toList();
  }

  @override
  Future<FarmEntity> getFarmById(String farmId) async {
    if (await _isOnline) {
      try {
        final remote = await _remoteDataSource.getFarmById(farmId);
        await _localDataSource.cacheFarm(remote);
        return remote.toEntity();
      } catch (e) {
        _log.warning('Remote fetch failed for farm $farmId: $e');
        return _getCachedFarm(farmId);
      }
    }
    return _getCachedFarm(farmId);
  }

  Future<FarmEntity> _getCachedFarm(String farmId) async {
    final cached = await _localDataSource.getFarmById(farmId);
    if (cached == null) {
      throw FarmNotFoundException('Farm $farmId not found in cache');
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

  @override
  Future<FieldEntity> createField(FieldEntity field) async {
    final model = FieldModel.fromEntity(field);
    final created = await _remoteDataSource.createField(model);
    await _localDataSource.cacheField(created);
    return created.toEntity();
  }

  @override
  Future<FieldEntity> updateField(FieldEntity field) async {
    final model = FieldModel.fromEntity(field);
    final updated = await _remoteDataSource.updateField(model);
    await _localDataSource.cacheField(updated);
    return updated.toEntity();
  }

  @override
  Future<void> deleteField(String fieldId) async {
    await _remoteDataSource.deleteField(fieldId);
    await _localDataSource.deleteField(fieldId);
  }

  @override
  Future<List<FieldEntity>> getFieldsByFarmId(String farmId) async {
    if (await _isOnline) {
      try {
        final remoteFields =
            await _remoteDataSource.getFieldsByFarmId(farmId);
        for (final field in remoteFields) {
          await _localDataSource.cacheField(field);
        }
        return remoteFields.map((m) => m.toEntity()).toList();
      } catch (e) {
        _log.warning('Remote fetch fields failed: $e');
      }
    }
    final cached = await _localDataSource.getFieldsByFarmId(farmId);
    return cached.map((m) => m.toEntity()).toList();
  }
}

/// Thrown when a farm cannot be found.
class FarmNotFoundException implements Exception {
  final String message;
  const FarmNotFoundException(this.message);

  @override
  String toString() => 'FarmNotFoundException: $message';
}
