import 'package:flutter_network/flutter_network.dart';
import 'package:logging/logging.dart';

import '../../domain/entities/irrigation_schedule_entity.dart';
import '../../domain/entities/irrigation_zone_entity.dart';
import '../../domain/repositories/irrigation_repository.dart';
import '../datasources/irrigation_local_datasource.dart';
import '../datasources/irrigation_remote_datasource.dart';
import '../models/irrigation_model.dart';

class IrrigationRepositoryImpl implements IrrigationRepository {
  final IrrigationRemoteDataSource _remoteDataSource;
  final IrrigationLocalDataSource _localDataSource;
  final ConnectivityService _connectivityService;
  final _log = Logger('IrrigationRepository');

  IrrigationRepositoryImpl({
    required IrrigationRemoteDataSource remoteDataSource,
    required IrrigationLocalDataSource localDataSource,
    required ConnectivityService connectivityService,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _connectivityService = connectivityService;

  bool get _isOnline => _connectivityService.currentStatus == ConnectivityStatus.online;

  @override
  Future<List<IrrigationZoneEntity>> getZones(String fieldId) async {
    if (_isOnline) {
      try {
        final remote = await _remoteDataSource.getZones(fieldId);
        await _localDataSource.cacheZones(fieldId, remote);
        return remote.map((m) => m.toEntity()).toList();
      } catch (e) {
        _log.warning('Remote fetch failed: $e');
      }
    }
    final cached = await _localDataSource.getZones(fieldId);
    return cached.map((m) => m.toEntity()).toList();
  }

  @override
  Future<IrrigationZoneEntity> getZoneById(String zoneId) async {
    final remote = await _remoteDataSource.getZones(zoneId);
    if (remote.isNotEmpty) return remote.first.toEntity();
    throw Exception('Zone $zoneId not found');
  }

  @override
  Future<IrrigationScheduleEntity> updateSchedule(IrrigationScheduleEntity schedule) async {
    final model = IrrigationScheduleModel.fromEntity(schedule);
    final updated = await _remoteDataSource.updateSchedule(model);
    return updated.toEntity();
  }

  @override
  Future<List<IrrigationScheduleEntity>> getSchedules(String zoneId) async {
    final remote = await _remoteDataSource.getSchedules(zoneId);
    return remote.map((m) => m.toEntity()).toList();
  }
}
