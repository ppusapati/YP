import 'package:equatable/equatable.dart';

/// Events for the traceability BLoC.
sealed class TraceabilityEvent extends Equatable {
  const TraceabilityEvent();

  @override
  List<Object?> get props => [];
}

/// Scan a QR code to retrieve a produce record.
class ScanQRCode extends TraceabilityEvent {
  const ScanQRCode(this.qrData);

  final String qrData;

  @override
  List<Object?> get props => [qrData];
}

/// Load a produce record by its ID.
class LoadProduceRecord extends TraceabilityEvent {
  const LoadProduceRecord(this.recordId);

  final String recordId;

  @override
  List<Object?> get props => [recordId];
}

/// Load the produce history for a farm.
class LoadFarmHistory extends TraceabilityEvent {
  const LoadFarmHistory(this.farmId);

  final String farmId;

  @override
  List<Object?> get props => [farmId];
}
