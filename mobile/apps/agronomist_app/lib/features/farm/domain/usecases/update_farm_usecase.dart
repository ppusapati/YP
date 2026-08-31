import '../entities/farm_entity.dart';
import '../repositories/farm_repository.dart';

/// Use case for updating an existing farm.
class UpdateFarmUseCase {
  final FarmRepository _repository;

  const UpdateFarmUseCase(this._repository);

  /// Updates a farm and returns the updated entity.
  Future<FarmEntity> call(FarmEntity farm) {
    return _repository.updateFarm(farm);
  }
}
