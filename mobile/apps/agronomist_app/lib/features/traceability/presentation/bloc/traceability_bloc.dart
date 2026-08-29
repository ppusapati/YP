import 'package:bloc/bloc.dart';

import '../../domain/usecases/create_trace_record_usecase.dart';
import '../../domain/usecases/get_trace_records_usecase.dart';
import 'traceability_event.dart';
import 'traceability_state.dart';

class TraceabilityBloc extends Bloc<TraceabilityEvent, TraceabilityState> {
  TraceabilityBloc({
    required GetTraceRecordsUseCase getTraceRecords,
    required CreateTraceRecordUseCase createTraceRecord,
  })  : _getTraceRecords = getTraceRecords,
        _createTraceRecord = createTraceRecord,
        super(const TraceabilityInitial()) {
    on<LoadTraceRecords>(_onLoadRecords);
    on<LoadTraceRecordById>(_onLoadRecordById);
    on<CreateTraceRecord>(_onCreateRecord);
  }

  final GetTraceRecordsUseCase _getTraceRecords;
  final CreateTraceRecordUseCase _createTraceRecord;

  Future<void> _onLoadRecords(
      LoadTraceRecords event, Emitter<TraceabilityState> emit) async {
    emit(const TraceabilityLoading());
    try {
      final records = await _getTraceRecords(
        fieldId: event.fieldId,
        batchNumber: event.batchNumber,
      );
      emit(TraceRecordsLoaded(records: records));
    } catch (e) {
      emit(TraceabilityError(message: e.toString()));
    }
  }

  Future<void> _onLoadRecordById(
      LoadTraceRecordById event, Emitter<TraceabilityState> emit) async {
    emit(const TraceabilityLoading());
    try {
      final records = await _getTraceRecords();
      final match = records.firstWhere((r) => r.id == event.id);
      emit(TraceRecordLoaded(record: match));
    } catch (e) {
      emit(TraceabilityError(message: e.toString()));
    }
  }

  Future<void> _onCreateRecord(
      CreateTraceRecord event, Emitter<TraceabilityState> emit) async {
    emit(const TraceabilityLoading());
    try {
      final record = await _createTraceRecord(event.record);
      emit(TraceRecordCreated(record: record));
    } catch (e) {
      emit(TraceabilityError(message: e.toString()));
    }
  }
}
