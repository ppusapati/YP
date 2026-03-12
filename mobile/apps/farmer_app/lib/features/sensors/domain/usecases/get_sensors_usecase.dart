import '../entities/sensor_entity.dart';
import '../repositories/sensor_repository.dart';

class GetSensorsUseCase {
  const GetSensorsUseCase(this._repository);

  final SensorRepository _repository;

  Future<List<Sensor>> call({SensorType? type}) async {
    if (type != null) {
      return _repository.getSensorsByType(type);
    }
    return _repository.getSensors();
  }
}
