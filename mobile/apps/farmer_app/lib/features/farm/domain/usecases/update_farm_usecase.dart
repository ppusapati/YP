import '../entities/farm_entity.dart';
import '../repositories/farm_repository.dart';

/// Use case for updating farm details and boundary.
class UpdateFarmUseCase {
  final FarmRepository _repository;

  const UpdateFarmUseCase(this._repository);

  /// Updates the farm and returns the updated entity.
  Future<FarmEntity> call(FarmEntity farm) {
    return _repository.updateFarm(farm);
  }
}
