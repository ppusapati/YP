import 'package:flutter_network/flutter_network.dart';
import 'package:logging/logging.dart';

import '../../domain/entities/advisory_entity.dart';
import '../../domain/repositories/crop_advisory_repository.dart';
import '../datasources/crop_advisory_local_datasource.dart';
import '../datasources/crop_advisory_remote_datasource.dart';
import '../models/advisory_model.dart';

class CropAdvisoryRepositoryImpl implements CropAdvisoryRepository {
  final CropAdvisoryRemoteDataSource _remoteDataSource;
  final CropAdvisoryLocalDataSource _localDataSource;
  final ConnectivityService _connectivityService;
  final _log = Logger('CropAdvisoryRepository');

  CropAdvisoryRepositoryImpl({
    required CropAdvisoryRemoteDataSource remoteDataSource,
    required CropAdvisoryLocalDataSource localDataSource,
    required ConnectivityService connectivityService,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _connectivityService = connectivityService;

  bool get _isOnline =>
      _connectivityService.currentStatus == ConnectivityStatus.online;

  @override
  Future<List<AdvisoryEntity>> getAdvisories({String? farmId}) async {
    if (_isOnline) {
      try {
        final remote = await _remoteDataSource.getAdvisories(farmId: farmId);
        await _localDataSource.cacheAdvisories(remote);
        return remote.map((m) => m.toEntity()).toList();
      } catch (e) {
        _log.warning('Remote fetch failed, falling back to cache: $e');
      }
    }
    final cached = await _localDataSource.getAdvisories();
    var entities = cached.map((m) => m.toEntity()).toList();
    if (farmId != null) {
      entities = entities.where((e) => e.farmId == farmId).toList();
    }
    return entities;
  }

  @override
  Future<AdvisoryEntity> getAdvisoryById(String id) async {
    if (_isOnline) {
      try {
        final remote = await _remoteDataSource.getAdvisoryById(id);
        await _localDataSource.cacheAdvisory(remote);
        return remote.toEntity();
      } catch (e) {
        _log.warning('Remote fetch failed for advisory $id: $e');
      }
    }
    final cached = await _localDataSource.getAdvisories();
    final match = cached.where((m) => m.id == id).firstOrNull;
    if (match == null) {
      throw Exception('Advisory $id not found in cache');
    }
    return match.toEntity();
  }

  @override
  Future<AdvisoryEntity> createAdvisory(AdvisoryEntity advisory) async {
    final model = AdvisoryModel.fromEntity(advisory);
    final created = await _remoteDataSource.createAdvisory(model);
    await _localDataSource.cacheAdvisory(created);
    return created.toEntity();
  }
}
