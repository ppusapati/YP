import 'package:equatable/equatable.dart';

import '../../domain/entities/trace_record_entity.dart';

sealed class TraceabilityState extends Equatable {
  const TraceabilityState();
  @override
  List<Object?> get props => [];
}

final class TraceabilityInitial extends TraceabilityState {
  const TraceabilityInitial();
}

final class TraceabilityLoading extends TraceabilityState {
  const TraceabilityLoading();
}

final class TraceRecordsLoaded extends TraceabilityState {
  const TraceRecordsLoaded({required this.records});
  final List<TraceRecordEntity> records;
  @override
  List<Object?> get props => [records];
}

final class TraceRecordLoaded extends TraceabilityState {
  const TraceRecordLoaded({required this.record});
  final TraceRecordEntity record;
  @override
  List<Object?> get props => [record];
}

final class TraceRecordCreated extends TraceabilityState {
  const TraceRecordCreated({required this.record});
  final TraceRecordEntity record;
  @override
  List<Object?> get props => [record];
}

final class TraceabilityError extends TraceabilityState {
  const TraceabilityError({required this.message});
  final String message;
  @override
  List<Object?> get props => [message];
}
