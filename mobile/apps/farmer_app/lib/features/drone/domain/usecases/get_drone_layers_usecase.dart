import '../entities/drone_layer_entity.dart';
import '../repositories/drone_repository.dart';

class GetDroneLayersUseCase {
  const GetDroneLayersUseCase(this._repository);

  final DroneRepository _repository;

  Future<List<DroneLayer>> call({
    required String fieldId,
    DroneLayerType? layerType,
  }) async {
    return _repository.getDroneLayers(
      fieldId: fieldId,
      layerType: layerType,
    );
  }
}
