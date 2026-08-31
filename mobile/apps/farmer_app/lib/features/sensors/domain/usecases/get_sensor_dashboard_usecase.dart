import '../entities/sensor_entity.dart';
import '../repositories/sensor_repository.dart';

class GetSensorDashboardUseCase {
  const GetSensorDashboardUseCase(this._repository);

  final SensorRepository _repository;

  Future<Map<String, Sensor>> call() async {
    return _repository.getSensorDashboard();
  }
}
