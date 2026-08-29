import 'package:equatable/equatable.dart';

import '../../domain/entities/satellite_data_entity.dart';
import '../../domain/entities/stress_alert_entity.dart';

sealed class SatelliteState extends Equatable {
  const SatelliteState();

  @override
  List<Object?> get props => [];
}

final class SatelliteInitial extends SatelliteState {
  const SatelliteInitial();
}

final class SatelliteLoading extends SatelliteState {
  const SatelliteLoading();
}

final class SatelliteTilesLoaded extends SatelliteState {
  const SatelliteTilesLoaded({required this.tiles});
  final List<SatelliteDataEntity> tiles;

  @override
  List<Object?> get props => [tiles];
}

final class StressAlertsLoaded extends SatelliteState {
  const StressAlertsLoaded({required this.alerts});
  final List<StressAlertEntity> alerts;

  @override
  List<Object?> get props => [alerts];
}

final class FieldSummaryLoaded extends SatelliteState {
  const FieldSummaryLoaded({required this.summary});
  final FieldAnalyticsSummary summary;

  @override
  List<Object?> get props => [summary];
}

final class SatelliteError extends SatelliteState {
  const SatelliteError({required this.message});
  final String message;

  @override
  List<Object?> get props => [message];
}
