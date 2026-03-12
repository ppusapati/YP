import '../../domain/entities/sensor_entity.dart';
import '../../domain/entities/sensor_reading_entity.dart';
import '../../domain/repositories/sensor_repository.dart';
import '../datasources/sensor_local_datasource.dart';
import '../datasources/sensor_remote_datasource.dart';
import '../models/sensor_model.dart';
import '../models/sensor_reading_model.dart';

class SensorRepositoryImpl implements SensorRepository {
  SensorRepositoryImpl({
    required SensorRemoteDataSource remoteDataSource,
    required SensorLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  final SensorRemoteDataSource _remoteDataSource;
  final SensorLocalDataSource _localDataSource;

  @override
  Future<List<Sensor>> getSensors() async {
    try {
      final remoteSensors = await _remoteDataSource.getSensors();
      await _localDataSource.cacheSensors(remoteSensors);
      return remoteSensors;
    } catch (_) {
      return _localDataSource.getCachedSensors();
    }
  }

  @override
  Future<List<Sensor>> getSensorsByType(SensorType type) async {
    try {
      return await _remoteDataSource.getSensorsByType(type.name);
    } catch (_) {
      final cached = await _localDataSource.getCachedSensors();
      return cached.where((s) => s.type == type).toList();
    }
  }

  @override
  Future<Sensor> getSensorById(String sensorId) async {
    try {
      return await _remoteDataSource.getSensorById(sensorId);
    } catch (_) {
      final cached = await _localDataSource.getCachedSensors();
      return cached.firstWhere(
        (s) => s.id == sensorId,
        orElse: () => throw Exception('Sensor not found in cache'),
      );
    }
  }

  @override
  Future<List<SensorReading>> getSensorReadings(
    String sensorId, {
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      final readings = await _remoteDataSource.getSensorReadings(
        sensorId,
        from: from,
        to: to,
      );
      await _localDataSource.cacheReadings(
        sensorId,
        readings.map((r) => SensorReadingModel.fromEntity(r)).toList(),
      );
      return readings;
    } catch (_) {
      return _localDataSource.getCachedReadings(sensorId);
    }
  }

  @override
  Future<Map<String, Sensor>> getSensorDashboard() async {
    try {
      return await _remoteDataSource.getSensorDashboard();
    } catch (_) {
      final cached = await _localDataSource.getCachedSensors();
      return {for (final s in cached) s.id: s};
    }
  }

  @override
  Future<void> refreshSensor(String sensorId) async {
    await _remoteDataSource.refreshSensor(sensorId);
  }
}
