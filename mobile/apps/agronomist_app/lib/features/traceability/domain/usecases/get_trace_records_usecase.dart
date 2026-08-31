import '../entities/trace_record_entity.dart';
import '../repositories/traceability_repository.dart';

class GetTraceRecordsUseCase {
  final TraceabilityRepository _repository;
  const GetTraceRecordsUseCase(this._repository);

  Future<List<TraceRecordEntity>> call({String? fieldId, String? batchNumber}) {
    return _repository.getTraceRecords(fieldId: fieldId, batchNumber: batchNumber);
  }
}
