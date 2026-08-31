import '../entities/irrigation_zone_entity.dart';
import '../repositories/irrigation_repository.dart';

class GetIrrigationPlanUseCase {
  final IrrigationRepository _repository;
  const GetIrrigationPlanUseCase(this._repository);

  Future<List<IrrigationZoneEntity>> call(String fieldId) {
    return _repository.getZones(fieldId);
  }
}
