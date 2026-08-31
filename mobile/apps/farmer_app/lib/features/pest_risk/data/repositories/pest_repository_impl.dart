import 'package:flutter_network/flutter_network.dart';
import 'package:logging/logging.dart';

import '../../domain/entities/pest_risk_entity.dart';
import '../../domain/repositories/pest_repository.dart';
import '../datasources/pest_local_datasource.dart';
import '../datasources/pest_remote_datasource.dart';
import '../models/pest_risk_model.dart';

/// Concrete [PestRepository] that coordinates between remote and local sources.
///
/// Strategy: attempt remote fetch first, cache results locally. On network
/// failure, fall back to local cache.
class PestRepositoryImpl implements PestRepository {
  PestRepositoryImpl({
    required PestRemoteDataSource remoteDataSource,
    required PestLocalDataSource localDataSource,
  })  : _remote = remoteDataSource,
        _local = localDataSource;

  final PestRemoteDataSource _remote;
  final PestLocalDataSource _local;
  static final _log = Logger('PestRepositoryImpl');

  @override
  Future<List<PestRiskZone>> getPestRiskZones({String? fieldId}) async {
    try {
      final zones = await _remote.fetchPestRiskZones(fieldId: fieldId);
      await _local.cachePestRiskZones(zones);
      return zones;
    } on ConnectException catch (e) {
      _log.warning('Remote fetch failed, using cache: $e');
      return _local.getCachedPestRiskZones();
    }
  }

  @override
  Future<List<PestAlert>> getPestAlerts({String? fieldId}) async {
    try {
      final alerts = await _remote.fetchPestAlerts(fieldId: fieldId);
      await _local.cachePestAlerts(alerts);
      return alerts;
    } on ConnectException catch (e) {
      _log.warning('Remote fetch failed, using cache: $e');
      return _local.getCachedPestAlerts();
    }
  }

  @override
  Future<List<PestRiskZone>> getPestRiskZonesByLevel(
    RiskLevel riskLevel,
  ) async {
    final allZones = await getPestRiskZones();
    return allZones.where((z) => z.riskLevel == riskLevel).toList();
  }

  @override
  Future<PestAlert> getPestAlertById(String alertId) async {
    return _remote.fetchPestAlertById(alertId);
  }

  @override
  Future<void> markAlertAsRead(String alertId) async {
    try {
      await _remote.markAlertAsRead(alertId);
    } on ConnectException catch (e) {
      _log.warning('Failed to mark alert as read remotely: $e');
      // Optimistic update: mark locally even if remote fails.
      final cached = await _local.getCachedPestAlerts();
      final updated = cached.map((a) {
        if (a.id == alertId) {
          return PestAlertModel.fromEntity(a.copyWith(isRead: true));
        }
        return a;
      }).toList();
      await _local.cachePestAlerts(updated);
    }
  }
}
