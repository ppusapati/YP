import 'package:flutter_network/flutter_network.dart';
import 'package:logging/logging.dart';

import '../../domain/entities/inspection_entity.dart';
import '../../domain/repositories/field_inspection_repository.dart';
import '../datasources/field_inspection_local_datasource.dart';
import '../datasources/field_inspection_remote_datasource.dart';
import '../models/inspection_model.dart';

/// Repository implementation with offline-first strategy.
class FieldInspectionRepositoryImpl implements FieldInspectionRepository {
  final FieldInspectionRemoteDataSource _remoteDataSource;
  final FieldInspectionLocalDataSource _localDataSource;
  final ConnectivityService _connectivityService;
  final _log = Logger('FieldInspectionRepository');

  FieldInspectionRepositoryImpl({
    required FieldInspectionRemoteDataSource remoteDataSource,
    required FieldInspectionLocalDataSource localDataSource,
    required ConnectivityService connectivityService,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _connectivityService = connectivityService;

  bool get _isOnline =>
      _connectivityService.currentStatus == ConnectivityStatus.online;

  @override
  Future<List<InspectionEntity>> getInspections({String? farmId}) async {
    if (_isOnline) {
      try {
        final remote =
            await _remoteDataSource.getInspections(farmId: farmId);
        await _localDataSource.cacheInspections(remote);
        return remote.map((m) => m.toEntity()).toList();
      } catch (e) {
        _log.warning('Remote fetch failed, falling back to cache: $e');
      }
    }
    final cached = await _localDataSource.getInspections();
    var entities = cached.map((m) => m.toEntity()).toList();
    if (farmId != null) {
      entities = entities.where((e) => e.farmId == farmId).toList();
    }
    return entities;
  }

  @override
  Future<InspectionEntity> getInspectionById(String id) async {
    if (_isOnline) {
      try {
        final remote = await _remoteDataSource.getInspectionById(id);
        await _localDataSource.cacheInspection(remote);
        return remote.toEntity();
      } catch (e) {
        _log.warning('Remote fetch failed for inspection $id: $e');
      }
    }
    final cached = await _localDataSource.getInspections();
    final match = cached.where((m) => m.id == id).firstOrNull;
    if (match == null) {
      throw Exception('Inspection $id not found in cache');
    }
    return match.toEntity();
  }

  @override
  Future<InspectionEntity> createInspection(
      InspectionEntity inspection) async {
    final model = InspectionModel.fromEntity(inspection);
    final created = await _remoteDataSource.createInspection(model);
    await _localDataSource.cacheInspection(created);
    return created.toEntity();
  }

  @override
  Future<InspectionEntity> submitInspection(String inspectionId) async {
    final submitted = await _remoteDataSource.submitInspection(inspectionId);
    await _localDataSource.cacheInspection(submitted);
    return submitted.toEntity();
  }
}
