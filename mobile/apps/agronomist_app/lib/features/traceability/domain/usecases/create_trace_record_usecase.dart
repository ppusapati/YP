import '../entities/trace_record_entity.dart';
import '../repositories/traceability_repository.dart';

class CreateTraceRecordUseCase {
  final TraceabilityRepository _repository;
  const CreateTraceRecordUseCase(this._repository);

  Future<TraceRecordEntity> call(TraceRecordEntity record) {
    return _repository.createTraceRecord(record);
  }
}
