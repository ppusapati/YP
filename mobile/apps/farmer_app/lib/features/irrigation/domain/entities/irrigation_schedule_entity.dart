import 'package:equatable/equatable.dart';

enum ScheduleStatus {
  pending,
  active,
  completed,
  cancelled,
  paused,
}

class IrrigationSchedule extends Equatable {
  const IrrigationSchedule({
    required this.id,
    required this.zoneId,
    required this.startTime,
    required this.duration,
    required this.waterVolume,
    required this.status,
  });

  final String id;
  final String zoneId;
  final DateTime startTime;
  final Duration duration;
  final double waterVolume;
  final ScheduleStatus status;

  DateTime get endTime => startTime.add(duration);
  bool get isActive => status == ScheduleStatus.active;
  bool get isPending => status == ScheduleStatus.pending;

  String get durationFormatted {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }

  IrrigationSchedule copyWith({
    String? id,
    String? zoneId,
    DateTime? startTime,
    Duration? duration,
    double? waterVolume,
    ScheduleStatus? status,
  }) {
    return IrrigationSchedule(
      id: id ?? this.id,
      zoneId: zoneId ?? this.zoneId,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
      waterVolume: waterVolume ?? this.waterVolume,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props =>
      [id, zoneId, startTime, duration, waterVolume, status];
}
