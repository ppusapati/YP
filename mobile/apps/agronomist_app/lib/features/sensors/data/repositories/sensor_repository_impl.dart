import '../../domain/entities/sensor_reading_entity.dart';
import '../../domain/repositories/sensor_repository.dart';
import '../datasources/sensor_remote_datasource.dart';

class SensorRepositoryImpl implements SensorRepository {
  final SensorRemoteDataSource _remoteDataSource;
  SensorRepositoryImpl({required SensorRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<List<SensorReadingEntity>> getSensorReadings(String fieldId) async {
    final remote = await _remoteDataSource.getSensorReadings(fieldId);
    return remote.map((m) => m.toEntity()).toList();
  }

  @override
  Future<SensorReadingEntity> getSensorDetail(String sensorId) async {
    throw UnimplementedError('getSensorDetail not yet implemented');
  }
}
