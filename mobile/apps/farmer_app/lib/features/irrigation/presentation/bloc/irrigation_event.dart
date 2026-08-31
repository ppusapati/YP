import 'package:equatable/equatable.dart';

import '../../domain/entities/irrigation_schedule_entity.dart';

sealed class IrrigationEvent extends Equatable {
  const IrrigationEvent();

  @override
  List<Object?> get props => [];
}

final class LoadZones extends IrrigationEvent {
  const LoadZones({required this.fieldId});

  final String fieldId;

  @override
  List<Object?> get props => [fieldId];
}

final class LoadSchedule extends IrrigationEvent {
  const LoadSchedule({required this.zoneId});

  final String zoneId;

  @override
  List<Object?> get props => [zoneId];
}

final class UpdateSchedule extends IrrigationEvent {
  const UpdateSchedule({required this.schedule});

  final IrrigationSchedule schedule;

  @override
  List<Object?> get props => [schedule];
}

final class LoadAlerts extends IrrigationEvent {
  const LoadAlerts({this.zoneId});

  final String? zoneId;

  @override
  List<Object?> get props => [zoneId];
}
