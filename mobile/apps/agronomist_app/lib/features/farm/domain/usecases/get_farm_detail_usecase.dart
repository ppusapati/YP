import '../entities/farm_entity.dart';
import '../repositories/farm_repository.dart';

/// Use case for retrieving a single farm by its ID.
class GetFarmDetailUseCase {
  final FarmRepository _repository;

  const GetFarmDetailUseCase(this._repository);

  /// Executes the use case and returns the farm for the given [farmId].
  Future<FarmEntity> call(String farmId) {
    return _repository.getFarmById(farmId);
  }
}
