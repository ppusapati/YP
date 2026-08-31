import '../entities/produce_record_entity.dart';
import '../repositories/traceability_repository.dart';

/// Retrieves the full produce history for a given farm.
class GetFarmHistoryUseCase {
  const GetFarmHistoryUseCase(this._repository);

  final TraceabilityRepository _repository;

  Future<List<ProduceRecord>> call(String farmId) {
    return _repository.getFarmHistory(farmId);
  }
}
