import 'package:equatable/equatable.dart';

import '../../domain/entities/pest_risk_entity.dart';

/// States for the pest risk BLoC.
sealed class PestState extends Equatable {
  const PestState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is requested.
class PestInitial extends PestState {
  const PestInitial();
}

/// Data is being fetched from the repository.
class PestLoading extends PestState {
  const PestLoading();
}

/// Pest risk zones have been loaded successfully.
class PestZonesLoaded extends PestState {
  const PestZonesLoaded({
    required this.zones,
    this.filteredZones,
    this.activeFilter,
  });

  /// All available zones.
  final List<PestRiskZone> zones;

  /// Zones after applying risk level filter (null when no filter active).
  final List<PestRiskZone>? filteredZones;

  /// The currently active risk level filter (null = show all).
  final RiskLevel? activeFilter;

  /// The zones to display, respecting the active filter.
  List<PestRiskZone> get displayZones => filteredZones ?? zones;

  @override
  List<Object?> get props => [zones, filteredZones, activeFilter];
}

/// Pest alerts have been loaded successfully.
class PestAlertsLoaded extends PestState {
  const PestAlertsLoaded({required this.alerts});

  final List<PestAlert> alerts;

  int get unreadCount => alerts.where((a) => !a.isRead).length;

  @override
  List<Object?> get props => [alerts];
}

/// An error occurred during data fetching.
class PestError extends PestState {
  const PestError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
