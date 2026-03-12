import '../entities/sensor_entity.dart';
import '../entities/sensor_reading_entity.dart';

abstract class SensorRepository {
  Future<List<Sensor>> getSensors();
  Future<List<Sensor>> getSensorsByType(SensorType type);
  Future<Sensor> getSensorById(String sensorId);
  Future<List<SensorReading>> getSensorReadings(
    String sensorId, {
    DateTime? from,
    DateTime? to,
  });
  Future<Map<String, Sensor>> getSensorDashboard();
  Future<void> refreshSensor(String sensorId);
}
