import 'package:equatable/equatable.dart';

import '../../domain/entities/produce_record_entity.dart';

/// States for the traceability BLoC.
sealed class TraceabilityState extends Equatable {
  const TraceabilityState();

  @override
  List<Object?> get props => [];
}

class TraceabilityInitial extends TraceabilityState {
  const TraceabilityInitial();
}

/// QR scanning is active.
class Scanning extends TraceabilityState {
  const Scanning();
}

/// Data is being fetched.
class TraceabilityLoading extends TraceabilityState {
  const TraceabilityLoading();
}

/// A produce record has been loaded (from scan or direct fetch).
class RecordLoaded extends TraceabilityState {
  const RecordLoaded(this.record);

  final ProduceRecord record;

  @override
  List<Object?> get props => [record];
}

/// Farm history has been loaded.
class FarmHistoryLoaded extends TraceabilityState {
  const FarmHistoryLoaded(this.records);

  final List<ProduceRecord> records;

  @override
  List<Object?> get props => [records];
}

class TraceabilityError extends TraceabilityState {
  const TraceabilityError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
