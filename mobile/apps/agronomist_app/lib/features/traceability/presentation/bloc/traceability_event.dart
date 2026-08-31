import 'package:equatable/equatable.dart';

import '../../domain/entities/trace_record_entity.dart';

sealed class TraceabilityEvent extends Equatable {
  const TraceabilityEvent();
  @override
  List<Object?> get props => [];
}

final class LoadTraceRecords extends TraceabilityEvent {
  const LoadTraceRecords({this.fieldId, this.batchNumber});
  final String? fieldId;
  final String? batchNumber;
  @override
  List<Object?> get props => [fieldId, batchNumber];
}

final class LoadTraceRecordById extends TraceabilityEvent {
  const LoadTraceRecordById({required this.id});
  final String id;
  @override
  List<Object?> get props => [id];
}

final class CreateTraceRecord extends TraceabilityEvent {
  const CreateTraceRecord({required this.record});
  final TraceRecordEntity record;
  @override
  List<Object?> get props => [record];
}
