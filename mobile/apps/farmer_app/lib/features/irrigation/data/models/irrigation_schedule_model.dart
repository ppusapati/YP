import '../../domain/entities/irrigation_schedule_entity.dart';

class IrrigationScheduleModel extends IrrigationSchedule {
  const IrrigationScheduleModel({
    required super.id,
    required super.zoneId,
    required super.startTime,
    required super.duration,
    required super.waterVolume,
    required super.status,
  });

  factory IrrigationScheduleModel.fromJson(Map<String, dynamic> json) {
    return IrrigationScheduleModel(
      id: json['id'] as String,
      zoneId: json['zone_id'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      duration: Duration(minutes: json['duration_minutes'] as int),
      waterVolume: (json['water_volume'] as num).toDouble(),
      status: ScheduleStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ScheduleStatus.pending,
      ),
    );
  }

  factory IrrigationScheduleModel.fromEntity(IrrigationSchedule entity) {
    return IrrigationScheduleModel(
      id: entity.id,
      zoneId: entity.zoneId,
      startTime: entity.startTime,
      duration: entity.duration,
      waterVolume: entity.waterVolume,
      status: entity.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'zone_id': zoneId,
      'start_time': startTime.toIso8601String(),
      'duration_minutes': duration.inMinutes,
      'water_volume': waterVolume,
      'status': status.name,
    };
  }
}
