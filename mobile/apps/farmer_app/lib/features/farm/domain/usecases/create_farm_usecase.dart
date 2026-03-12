import '../entities/farm_entity.dart';
import '../repositories/farm_repository.dart';

/// Use case for creating a new farm with boundary coordinates.
class CreateFarmUseCase {
  final FarmRepository _repository;

  const CreateFarmUseCase(this._repository);

  /// Creates a new farm and returns the persisted entity.
  Future<FarmEntity> call(FarmEntity farm) {
    return _repository.createFarm(farm);
  }
}
