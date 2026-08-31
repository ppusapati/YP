import 'package:flutter_network/flutter_network.dart';
import 'package:logging/logging.dart';

import '../../domain/entities/satellite_data_entity.dart';
import '../../domain/entities/stress_alert_entity.dart';
import '../../domain/repositories/satellite_repository.dart';
import '../datasources/satellite_local_datasource.dart';
import '../datasources/satellite_remote_datasource.dart';

class SatelliteRepositoryImpl implements SatelliteRepository {
  final SatelliteRemoteDataSource _remoteDataSource;
  final SatelliteLocalDataSource _localDataSource;
  final ConnectivityService _connectivityService;
  final _log = Logger('SatelliteRepository');

  SatelliteRepositoryImpl({
    required SatelliteRemoteDataSource remoteDataSource,
    required SatelliteLocalDataSource localDataSource,
    required ConnectivityService connectivityService,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _connectivityService = connectivityService;

  bool get _isOnline =>
      _connectivityService.currentStatus == ConnectivityStatus.online;

  @override
  Future<List<SatelliteDataEntity>> getTilesForField(String fieldId) async {
    final remote = await _remoteDataSource.getTilesForField(fieldId);
    return remote.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<StressAlertEntity>> getStressAlerts(String farmId) async {
    if (_isOnline) {
      try {
        final remote = await _remoteDataSource.getStressAlerts(farmId);
        await _localDataSource.cacheStressAlerts(farmId, remote);
        return remote.map((m) => m.toEntity()).toList();
      } catch (e) {
        _log.warning('Remote fetch stress alerts failed: $e');
      }
    }
    final cached = await _localDataSource.getStressAlerts(farmId);
    return cached.map((m) => m.toEntity()).toList();
  }

  @override
  Future<FieldAnalyticsSummary> getFieldAnalyticsSummary(
      String farmId, String fieldId) async {
    final data = await _remoteDataSource.getFieldSummary(farmId, fieldId);
    final summary = data['summary'] as Map<String, dynamic>;
    return FieldAnalyticsSummary(
      farmId: farmId,
      fieldId: fieldId,
      averageNdvi: (summary['average_ndvi'] as num?)?.toDouble() ?? 0,
      averageNdwi: (summary['average_ndwi'] as num?)?.toDouble() ?? 0,
      healthScore: (summary['health_score'] as num?)?.toDouble() ?? 0,
      totalTiles: (summary['total_tiles'] as num?)?.toInt() ?? 0,
      lastCaptureDate: summary['last_capture_date'] != null
          ? DateTime.parse(summary['last_capture_date'] as String)
          : DateTime.now(),
    );
  }

  @override
  Future<TemporalAnalysis> runTemporalAnalysis(
      String farmId, String fieldId, String type) async {
    final data = await _remoteDataSource.getFieldSummary(farmId, fieldId);
    return TemporalAnalysis(
      farmId: farmId,
      fieldId: fieldId,
      analysisType: type,
      dataPoints: [],
      trend: data['trend'] as String? ?? 'stable',
      summary: data['summary_text'] as String? ?? 'No analysis available',
    );
  }
}
