import 'package:equatable/equatable.dart';

import '../../domain/entities/irrigation_alert_entity.dart';
import '../../domain/entities/irrigation_schedule_entity.dart';
import '../../domain/entities/irrigation_zone_entity.dart';

sealed class IrrigationState extends Equatable {
  const IrrigationState();

  @override
  List<Object?> get props => [];
}

final class IrrigationInitial extends IrrigationState {
  const IrrigationInitial();
}

final class IrrigationLoading extends IrrigationState {
  const IrrigationLoading();
}

final class ZonesLoaded extends IrrigationState {
  const ZonesLoaded({required this.zones});

  final List<IrrigationZone> zones;

  int get activeCount =>
      zones.where((z) => z.status == IrrigationZoneStatus.irrigating).length;
  int get needsIrrigationCount => zones.where((z) => z.needsIrrigation).length;

  @override
  List<Object?> get props => [zones];
}

final class ScheduleLoaded extends IrrigationState {
  const ScheduleLoaded({
    required this.zoneId,
    required this.schedules,
  });

  final String zoneId;
  final List<IrrigationSchedule> schedules;

  List<IrrigationSchedule> get activeSchedules =>
      schedules.where((s) => s.isActive).toList();
  List<IrrigationSchedule> get pendingSchedules =>
      schedules.where((s) => s.isPending).toList();

  @override
  List<Object?> get props => [zoneId, schedules];
}

final class AlertsLoaded extends IrrigationState {
  const AlertsLoaded({required this.alerts});

  final List<IrrigationAlert> alerts;

  int get unreadCount => alerts.where((a) => !a.isRead).length;
  int get criticalCount => alerts.where((a) => a.isCritical).length;

  @override
  List<Object?> get props => [alerts];
}

final class IrrigationError extends IrrigationState {
  const IrrigationError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
