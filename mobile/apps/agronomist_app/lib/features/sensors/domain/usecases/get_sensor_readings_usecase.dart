import '../entities/sensor_reading_entity.dart';
import '../repositories/sensor_repository.dart';

class GetSensorReadingsUseCase {
  final SensorRepository _repository;
  const GetSensorReadingsUseCase(this._repository);
  Future<List<SensorReadingEntity>> call(String fieldId) => _repository.getSensorReadings(fieldId);
}
