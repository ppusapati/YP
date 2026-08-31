import '../entities/irrigation_zone_entity.dart';
import '../repositories/irrigation_repository.dart';

class GetIrrigationZonesUseCase {
  const GetIrrigationZonesUseCase(this._repository);

  final IrrigationRepository _repository;

  Future<List<IrrigationZone>> call(String fieldId) async {
    return _repository.getIrrigationZones(fieldId);
  }
}
