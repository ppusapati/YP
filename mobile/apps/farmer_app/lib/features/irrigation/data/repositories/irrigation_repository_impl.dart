import '../../domain/entities/irrigation_alert_entity.dart';
import '../../domain/entities/irrigation_schedule_entity.dart';
import '../../domain/entities/irrigation_zone_entity.dart';
import '../../domain/repositories/irrigation_repository.dart';
import '../datasources/irrigation_local_datasource.dart';
import '../datasources/irrigation_remote_datasource.dart';
import '../models/irrigation_schedule_model.dart';
import '../models/irrigation_zone_model.dart';

class IrrigationRepositoryImpl implements IrrigationRepository {
  IrrigationRepositoryImpl({
    required IrrigationRemoteDataSource remoteDataSource,
    required IrrigationLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  final IrrigationRemoteDataSource _remoteDataSource;
  final IrrigationLocalDataSource _localDataSource;

  @override
  Future<List<IrrigationZone>> getIrrigationZones(String fieldId) async {
    try {
      final zones = await _remoteDataSource.getZones(fieldId);
      await _localDataSource.cacheZones(fieldId, zones);
      return zones;
    } catch (_) {
      return _localDataSource.getCachedZones(fieldId);
    }
  }

  @override
  Future<IrrigationZone> getZoneById(String zoneId) async {
    return _remoteDataSource.getZoneById(zoneId);
  }

  @override
  Future<List<IrrigationSchedule>> getSchedules(String zoneId) async {
    try {
      final schedules = await _remoteDataSource.getSchedules(zoneId);
      await _localDataSource.cacheSchedules(zoneId, schedules);
      return schedules;
    } catch (_) {
      return _localDataSource.getCachedSchedules(zoneId);
    }
  }

  @override
  Future<IrrigationSchedule> updateSchedule(
      IrrigationSchedule schedule) async {
    final model = IrrigationScheduleModel.fromEntity(schedule);
    return _remoteDataSource.updateSchedule(model);
  }

  @override
  Future<void> deleteSchedule(String scheduleId) async {
    await _remoteDataSource.deleteSchedule(scheduleId);
  }

  @override
  Future<List<IrrigationAlert>> getAlerts({String? zoneId}) async {
    final rawAlerts = await _remoteDataSource.getAlerts(zoneId: zoneId);
    return rawAlerts.map(_mapAlert).toList();
  }

  @override
  Future<void> markAlertRead(String alertId) async {
    // Handled via remote; no local caching needed for alerts
  }

  IrrigationAlert _mapAlert(Map<String, dynamic> json) {
    return IrrigationAlert(
      id: json['id'] as String,
      zoneId: json['zone_id'] as String,
      type: AlertType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AlertType.systemFailure,
      ),
      message: json['message'] as String,
      severity: AlertSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => AlertSeverity.info,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['is_read'] as bool? ?? false,
    );
  }
}
