import '../entities/sensor_reading_entity.dart';

abstract class SensorRepository {
  Future<List<SensorReadingEntity>> getSensorReadings(String fieldId);
  Future<SensorReadingEntity> getSensorDetail(String sensorId);
}
