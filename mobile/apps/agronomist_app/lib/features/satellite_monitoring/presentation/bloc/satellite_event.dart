import 'package:equatable/equatable.dart';

sealed class SatelliteEvent extends Equatable {
  const SatelliteEvent();

  @override
  List<Object?> get props => [];
}

final class LoadSatelliteTiles extends SatelliteEvent {
  const LoadSatelliteTiles({required this.fieldId});
  final String fieldId;

  @override
  List<Object?> get props => [fieldId];
}

final class LoadStressAlerts extends SatelliteEvent {
  const LoadStressAlerts({required this.farmId});
  final String farmId;

  @override
  List<Object?> get props => [farmId];
}

final class LoadFieldSummary extends SatelliteEvent {
  const LoadFieldSummary({required this.farmId, required this.fieldId});
  final String farmId;
  final String fieldId;

  @override
  List<Object?> get props => [farmId, fieldId];
}
