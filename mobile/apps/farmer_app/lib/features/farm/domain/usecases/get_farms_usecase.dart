import '../entities/farm_entity.dart';
import '../repositories/farm_repository.dart';

/// Use case for retrieving all farms belonging to a user.
class GetFarmsUseCase {
  final FarmRepository _repository;

  const GetFarmsUseCase(this._repository);

  /// Executes the use case and returns a list of farms for the given [userId].
  Future<List<FarmEntity>> call(String userId) {
    return _repository.getFarms(userId);
  }
}
