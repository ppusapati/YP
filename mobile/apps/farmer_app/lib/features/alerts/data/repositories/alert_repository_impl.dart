import 'package:flutter_network/flutter_network.dart';
import 'package:logging/logging.dart';

import '../../domain/entities/alert_entity.dart';
import '../../domain/repositories/alert_repository.dart';
import '../datasources/alert_local_datasource.dart';
import '../datasources/alert_remote_datasource.dart';
import '../models/alert_model.dart';

class AlertRepositoryImpl implements AlertRepository {
  AlertRepositoryImpl({
    required AlertRemoteDataSource remoteDataSource,
    required AlertLocalDataSource localDataSource,
    required ConnectivityService connectivityService,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _connectivityService = connectivityService;

  final AlertRemoteDataSource _remoteDataSource;
  final AlertLocalDataSource _localDataSource;
  final ConnectivityService _connectivityService;
  static final _log = Logger('AlertRepository');

  @override
  Future<List<Alert>> getAlerts({
    String? farmId,
    AlertSeverity? severity,
  }) async {
    if (_connectivityService.currentStatus == ConnectivityStatus.online) {
      try {
        final remoteAlerts = await _remoteDataSource.getAlerts(
          farmId: farmId,
          severity: severity?.name,
        );
        await _localDataSource.cacheAlerts(remoteAlerts);
        return remoteAlerts;
      } on ConnectException catch (e) {
        _log.warning('Failed to fetch remote alerts: $e');
        return _getCachedFiltered(farmId: farmId, severity: severity);
      }
    }
    return _getCachedFiltered(farmId: farmId, severity: severity);
  }

  Future<List<Alert>> _getCachedFiltered({
    String? farmId,
    AlertSeverity? severity,
  }) async {
    var alerts = await _localDataSource.getCachedAlerts();
    if (farmId != null) {
      alerts = alerts.where((a) => a.farmId == farmId).toList().cast();
    }
    if (severity != null) {
      alerts = alerts.where((a) => a.severity == severity).toList().cast();
    }
    return alerts;
  }

  @override
  Future<Alert> getAlertById(String alertId) async {
    if (_connectivityService.currentStatus == ConnectivityStatus.online) {
      try {
        return await _remoteDataSource.getAlertById(alertId);
      } on ConnectException catch (e) {
        _log.warning('Failed to fetch alert $alertId: $e');
      }
    }
    final cached = await _localDataSource.getCachedAlerts();
    return cached.firstWhere(
      (a) => a.id == alertId,
      orElse: () => throw Exception('Alert not found'),
    );
  }

  @override
  Future<void> markAlertRead(String alertId) async {
    await _localDataSource.markAlertRead(alertId);
    if (_connectivityService.currentStatus == ConnectivityStatus.online) {
      try {
        await _remoteDataSource.markAlertRead(alertId);
      } on ConnectException catch (e) {
        _log.warning('Failed to sync read status for $alertId: $e');
      }
    }
  }

  @override
  Future<void> markAllAlertsRead({String? farmId}) async {
    await _localDataSource.markAllAlertsRead();
    if (_connectivityService.currentStatus == ConnectivityStatus.online) {
      try {
        await _remoteDataSource.markAllAlertsRead(farmId: farmId);
      } on ConnectException catch (e) {
        _log.warning('Failed to sync mark-all-read: $e');
      }
    }
  }

  @override
  Future<int> getUnreadCount({String? farmId}) async {
    if (_connectivityService.currentStatus == ConnectivityStatus.online) {
      try {
        return await _remoteDataSource.getUnreadCount(farmId: farmId);
      } on ConnectException catch (e) {
        _log.warning('Failed to get remote unread count: $e');
      }
    }
    return _localDataSource.getUnreadCount();
  }

  @override
  Future<List<Alert>> refreshAlerts({String? farmId}) async {
    final remoteAlerts = await _remoteDataSource.getAlerts(farmId: farmId);
    final models = remoteAlerts
        .map((a) => AlertModel.fromEntity(a))
        .toList();
    await _localDataSource.cacheAlerts(models);
    return remoteAlerts;
  }
}
