import '../entities/drone_layer_entity.dart';
import '../repositories/drone_repository.dart';

class GetDroneFlightsUseCase {
  const GetDroneFlightsUseCase(this._repository);

  final DroneRepository _repository;

  Future<List<DroneFlight>> call({required String fieldId}) async {
    return _repository.getDroneFlights(fieldId: fieldId);
  }
}
