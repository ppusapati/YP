import 'package:equatable/equatable.dart';

import '../../domain/entities/alert_entity.dart';

sealed class AlertState extends Equatable {
  const AlertState();

  @override
  List<Object?> get props => [];
}

final class AlertInitial extends AlertState {
  const AlertInitial();
}

final class AlertLoading extends AlertState {
  const AlertLoading();
}

final class AlertsLoaded extends AlertState {
  const AlertsLoaded({
    required this.alerts,
    required this.unreadCount,
    this.activeSeverityFilter,
    this.activeTypeFilter,
  });

  final List<Alert> alerts;
  final int unreadCount;
  final AlertSeverity? activeSeverityFilter;
  final AlertType? activeTypeFilter;

  List<Alert> get filteredAlerts {
    var result = alerts;
    if (activeSeverityFilter != null) {
      result = result.where((a) => a.severity == activeSeverityFilter).toList();
    }
    if (activeTypeFilter != null) {
      result = result.where((a) => a.type == activeTypeFilter).toList();
    }
    return result;
  }

  AlertsLoaded copyWith({
    List<Alert>? alerts,
    int? unreadCount,
    AlertSeverity? Function()? activeSeverityFilter,
    AlertType? Function()? activeTypeFilter,
  }) {
    return AlertsLoaded(
      alerts: alerts ?? this.alerts,
      unreadCount: unreadCount ?? this.unreadCount,
      activeSeverityFilter: activeSeverityFilter != null
          ? activeSeverityFilter()
          : this.activeSeverityFilter,
      activeTypeFilter: activeTypeFilter != null
          ? activeTypeFilter()
          : this.activeTypeFilter,
    );
  }

  @override
  List<Object?> get props => [
        alerts,
        unreadCount,
        activeSeverityFilter,
        activeTypeFilter,
      ];
}

final class AlertError extends AlertState {
  const AlertError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
