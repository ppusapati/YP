import 'package:equatable/equatable.dart';

enum ZoneStatus {
  active,
  idle,
  scheduled,
  error;

  String get displayName => switch (this) {
        active => 'Active',
        idle => 'Idle',
        scheduled => 'Scheduled',
        error => 'Error',
      };
}

class IrrigationZone extends Equatable {
  final String id;
  final String name;
  final String fieldId;
  final ZoneStatus status;
  final double moistureLevel;
  final double flowRate;

  const IrrigationZone({
    required this.id,
    required this.name,
    required this.fieldId,
    required this.status,
    required this.moistureLevel,
    required this.flowRate,
  });

  @override
  List<Object?> get props => [id, name, fieldId, status, moistureLevel, flowRate];
}

class IrrigationSchedule extends Equatable {
  final String id;
  final String zoneId;
  final DateTime startTime;
  final Duration duration;
  final bool isRecurring;
  final List<int> daysOfWeek;

  const IrrigationSchedule({
    required this.id,
    required this.zoneId,
    required this.startTime,
    required this.duration,
    this.isRecurring = false,
    this.daysOfWeek = const [],
  });

  @override
  List<Object?> get props =>
      [id, zoneId, startTime, duration, isRecurring, daysOfWeek];
}

class IrrigationAlert extends Equatable {
  final String id;
  final String zoneId;
  final String message;
  final DateTime timestamp;
  final bool isResolved;

  const IrrigationAlert({
    required this.id,
    required this.zoneId,
    required this.message,
    required this.timestamp,
    this.isResolved = false,
  });

  @override
  List<Object?> get props => [id, zoneId, message, timestamp, isResolved];
}
