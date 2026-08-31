import '../entities/sensor_reading_entity.dart';
import '../repositories/sensor_repository.dart';

class GetSensorReadingsUseCase {
  const GetSensorReadingsUseCase(this._repository);

  final SensorRepository _repository;

  Future<List<SensorReading>> call({
    required String sensorId,
    DateTime? from,
    DateTime? to,
  }) async {
    return _repository.getSensorReadings(sensorId, from: from, to: to);
  }
}
