import '../entities/farm_entity.dart';
import '../repositories/farm_repository.dart';

/// Use case for retrieving all farms managed by the agronomist.
class GetFarmsUseCase {
  final FarmRepository _repository;

  const GetFarmsUseCase(this._repository);

  /// Executes the use case and returns a list of all client farms.
  Future<List<FarmEntity>> call() {
    return _repository.getFarms();
  }
}
