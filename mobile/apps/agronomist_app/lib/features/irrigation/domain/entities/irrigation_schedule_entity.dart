import 'package:equatable/equatable.dart';

enum ScheduleFrequency {
  daily,
  everyOtherDay,
  weekly,
  biweekly,
  custom,
}

class IrrigationScheduleEntity extends Equatable {
  const IrrigationScheduleEntity({
    required this.id,
    required this.zoneId,
    required this.startTime,
    required this.duration,
    required this.frequency,
    required this.enabled,
  });

  final String id;
  final String zoneId;
  final DateTime startTime;
  final Duration duration;
  final ScheduleFrequency frequency;
  final bool enabled;

  String get durationFormatted {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }

  String get frequencyLabel {
    return switch (frequency) {
      ScheduleFrequency.daily => 'Daily',
      ScheduleFrequency.everyOtherDay => 'Every Other Day',
      ScheduleFrequency.weekly => 'Weekly',
      ScheduleFrequency.biweekly => 'Bi-weekly',
      ScheduleFrequency.custom => 'Custom',
    };
  }

  IrrigationScheduleEntity copyWith({
    String? id,
    String? zoneId,
    DateTime? startTime,
    Duration? duration,
    ScheduleFrequency? frequency,
    bool? enabled,
  }) {
    return IrrigationScheduleEntity(
      id: id ?? this.id,
      zoneId: zoneId ?? this.zoneId,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
      frequency: frequency ?? this.frequency,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  List<Object?> get props =>
      [id, zoneId, startTime, duration, frequency, enabled];
}
