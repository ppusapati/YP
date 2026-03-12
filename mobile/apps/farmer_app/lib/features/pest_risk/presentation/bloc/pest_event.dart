import 'package:equatable/equatable.dart';

import '../../domain/entities/pest_risk_entity.dart';

/// Events for the pest risk BLoC.
sealed class PestEvent extends Equatable {
  const PestEvent();

  @override
  List<Object?> get props => [];
}

/// Request to load all pest risk zones, optionally for a specific [fieldId].
class LoadPestRiskZones extends PestEvent {
  const LoadPestRiskZones({this.fieldId});

  final String? fieldId;

  @override
  List<Object?> get props => [fieldId];
}

/// Request to load pest alerts, optionally for a specific [fieldId].
class LoadPestAlerts extends PestEvent {
  const LoadPestAlerts({this.fieldId});

  final String? fieldId;

  @override
  List<Object?> get props => [fieldId];
}

/// Filter currently loaded zones by [riskLevel].
class FilterByRiskLevel extends PestEvent {
  const FilterByRiskLevel(this.riskLevel);

  final RiskLevel? riskLevel;

  @override
  List<Object?> get props => [riskLevel];
}

/// Mark a specific alert as read.
class MarkAlertRead extends PestEvent {
  const MarkAlertRead(this.alertId);

  final String alertId;

  @override
  List<Object?> get props => [alertId];
}
