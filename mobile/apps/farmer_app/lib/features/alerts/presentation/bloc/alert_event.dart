import 'package:equatable/equatable.dart';

import '../../domain/entities/alert_entity.dart';

sealed class AlertEvent extends Equatable {
  const AlertEvent();

  @override
  List<Object?> get props => [];
}

final class LoadAlerts extends AlertEvent {
  const LoadAlerts({this.farmId});
  final String? farmId;

  @override
  List<Object?> get props => [farmId];
}

final class MarkRead extends AlertEvent {
  const MarkRead(this.alertId);
  final String alertId;

  @override
  List<Object?> get props => [alertId];
}

final class MarkAllRead extends AlertEvent {
  const MarkAllRead({this.farmId});
  final String? farmId;

  @override
  List<Object?> get props => [farmId];
}

final class FilterAlerts extends AlertEvent {
  const FilterAlerts({this.severity, this.type});
  final AlertSeverity? severity;
  final AlertType? type;

  @override
  List<Object?> get props => [severity, type];
}

final class RefreshAlerts extends AlertEvent {
  const RefreshAlerts({this.farmId});
  final String? farmId;

  @override
  List<Object?> get props => [farmId];
}
