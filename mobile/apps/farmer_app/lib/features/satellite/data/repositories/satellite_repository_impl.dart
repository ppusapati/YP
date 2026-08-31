import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logging/logging.dart';

import '../../domain/entities/crop_health_entity.dart';
import '../../domain/entities/satellite_entity.dart';
import '../../domain/repositories/satellite_repository.dart';
import '../datasources/satellite_local_datasource.dart';
import '../datasources/satellite_remote_datasource.dart';

/// Repository implementation that fetches satellite data from ConnectRPC,
/// caches in Drift, and serves from cache when offline.
class SatelliteRepositoryImpl implements SatelliteRepository {
  SatelliteRepositoryImpl({
    required SatelliteRemoteDataSource remoteDataSource,
    required SatelliteLocalDataSource localDataSource,
    required Connectivity connectivity,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _connectivity = connectivity;

  final SatelliteRemoteDataSource _remoteDataSource;
  final SatelliteLocalDataSource _localDataSource;
  final Connectivity _connectivity;
  final _log = Logger('SatelliteRepository');

  Future<bool> get _isOnline async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  @override
  Future<List<SatelliteTile>> getSatelliteTiles({
    required String fieldId,
    SatelliteLayerType? layerType,
    DateTime? from,
    DateTime? to,
  }) async {
    if (await _isOnline) {
      try {
        final remoteTiles = await _remoteDataSource.getSatelliteTiles(
          fieldId: fieldId,
          layerType: layerType,
          from: from,
          to: to,
        );
        await _localDataSource.cacheTiles(remoteTiles);
        return remoteTiles.map((m) => m.toEntity()).toList();
      } catch (e) {
        _log.warning('Remote satellite tiles fetch failed: $e');
      }
    }
    final cached = await _localDataSource.getCachedTiles(fieldId);
    return cached.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<NdviDataPoint>> getNdviHistory({
    required String fieldId,
    required DateTime from,
    required DateTime to,
  }) async {
    if (await _isOnline) {
      try {
        final remoteData = await _remoteDataSource.getNdviHistory(
          fieldId: fieldId,
          from: from,
          to: to,
        );
        await _localDataSource.cacheNdviHistory(fieldId, remoteData);
        return remoteData.map((m) => m.toEntity()).toList();
      } catch (e) {
        _log.warning('Remote NDVI history fetch failed: $e');
      }
    }
    final cached = await _localDataSource.getCachedNdviHistory(fieldId);
    return cached.map((m) => m.toEntity()).toList();
  }

  @override
  Future<CropHealthEntity> getCropHealth({required String fieldId}) async {
    if (await _isOnline) {
      try {
        final remoteData =
            await _remoteDataSource.getCropHealth(fieldId: fieldId);
        await _localDataSource.cacheCropHealth(fieldId, remoteData);
        return _parseCropHealth(remoteData);
      } catch (e) {
        _log.warning('Remote crop health fetch failed: $e');
      }
    }
    final cached = await _localDataSource.getCachedCropHealth(fieldId);
    if (cached == null) {
      throw CropHealthNotFoundException(
          'Crop health for field $fieldId not found in cache');
    }
    return _parseCropHealth(cached);
  }

  @override
  Future<List<CropHealthEntity>> getCropHealthByFarm({
    required String farmId,
  }) async {
    final remoteList =
        await _remoteDataSource.getCropHealthByFarm(farmId: farmId);
    return remoteList.map(_parseCropHealth).toList();
  }

  CropHealthEntity _parseCropHealth(Map<String, dynamic> data) {
    final timeSeriesRaw = data['time_series'] as List<dynamic>? ?? [];
    final timeSeries = timeSeriesRaw.map((dp) {
      final point = dp as Map<String, dynamic>;
      return CropHealthDataPoint(
        date: point['date'] != null
            ? DateTime.fromMillisecondsSinceEpoch(
                (point['date'] as num).toInt())
            : DateTime.now(),
        ndviMean: (point['ndvi_mean'] as num?)?.toDouble() ?? 0.0,
        ndviMin: (point['ndvi_min'] as num?)?.toDouble() ?? 0.0,
        ndviMax: (point['ndvi_max'] as num?)?.toDouble() ?? 0.0,
        growthRate: (point['growth_rate'] as num?)?.toDouble() ?? 0.0,
      );
    }).toList();

    return CropHealthEntity(
      fieldId: data['field_id'] as String? ?? '',
      fieldName: data['field_name'] as String? ?? '',
      timeSeries: timeSeries,
      overallStatus: CropHealthStatus.values.firstWhere(
        (e) => e.name == data['overall_status'],
        orElse: () => CropHealthStatus.moderate,
      ),
      currentNdvi: (data['current_ndvi'] as num?)?.toDouble() ?? 0.0,
      trendPercent: (data['trend_percent'] as num?)?.toDouble() ?? 0.0,
      lastUpdated: data['last_updated'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (data['last_updated'] as num).toInt())
          : DateTime.now(),
    );
  }
}

class CropHealthNotFoundException implements Exception {
  final String message;
  const CropHealthNotFoundException(this.message);

  @override
  String toString() => 'CropHealthNotFoundException: $message';
}
