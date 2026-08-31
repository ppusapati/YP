import '../entities/produce_record_entity.dart';
import '../repositories/traceability_repository.dart';

/// Retrieves a produce traceability record by ID.
class GetProduceRecordUseCase {
  const GetProduceRecordUseCase(this._repository);

  final TraceabilityRepository _repository;

  Future<ProduceRecord> call(String recordId) {
    return _repository.getProduceRecord(recordId);
  }
}
