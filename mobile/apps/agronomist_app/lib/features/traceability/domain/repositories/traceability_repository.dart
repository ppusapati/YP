import '../entities/trace_record_entity.dart';

abstract class TraceabilityRepository {
  Future<List<TraceRecordEntity>> getTraceRecords({String? fieldId, String? batchNumber});
  Future<TraceRecordEntity> getTraceRecordById(String id);
  Future<TraceRecordEntity> createTraceRecord(TraceRecordEntity record);
}
