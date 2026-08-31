import '../../domain/entities/irrigation_zone_entity.dart';
import '../../domain/entities/irrigation_schedule_entity.dart';

class IrrigationZoneModel {
  final String id;
  final String fieldId;
  final String name;
  final String waterSource;
  final double areaHectares;
  final String status;
  final double flowRate;

  const IrrigationZoneModel({
    required this.id,
    required this.fieldId,
    required this.name,
    required this.waterSource,
    required this.areaHectares,
    required this.status,
    required this.flowRate,
  });

  factory IrrigationZoneModel.fromJson(Map<String, dynamic> json) {
    return IrrigationZoneModel(
      id: json['id'] as String,
      fieldId: json['field_id'] as String,
      name: json['name'] as String,
      waterSource: json['water_source'] as String? ?? '',
      areaHectares: (json['area_hectares'] as num).toDouble(),
      status: json['status'] as String? ?? 'inactive',
      flowRate: (json['flow_rate'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'field_id': fieldId, 'name': name,
    'water_source': waterSource, 'area_hectares': areaHectares,
    'status': status, 'flow_rate': flowRate,
  };

  IrrigationZoneEntity toEntity() {
    return IrrigationZoneEntity(
      id: id, fieldId: fieldId, name: name,
      waterSource: waterSource, areaHectares: areaHectares,
      status: IrrigationZoneStatus.values.firstWhere(
        (e) => e.name == status, orElse: () => IrrigationZoneStatus.inactive),
      flowRate: flowRate,
    );
  }
}

class IrrigationScheduleModel {
  final String id;
  final String zoneId;
  final DateTime startTime;
  final int durationMinutes;
  final String frequency;
  final bool enabled;

  const IrrigationScheduleModel({
    required this.id,
    required this.zoneId,
    required this.startTime,
    required this.durationMinutes,
    required this.frequency,
    required this.enabled,
  });

  factory IrrigationScheduleModel.fromJson(Map<String, dynamic> json) {
    return IrrigationScheduleModel(
      id: json['id'] as String,
      zoneId: json['zone_id'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      durationMinutes: json['duration_minutes'] as int? ?? 30,
      frequency: json['frequency'] as String? ?? 'daily',
      enabled: json['enabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'zone_id': zoneId,
    'start_time': startTime.toIso8601String(),
    'duration_minutes': durationMinutes,
    'frequency': frequency, 'enabled': enabled,
  };

  IrrigationScheduleEntity toEntity() {
    return IrrigationScheduleEntity(
      id: id, zoneId: zoneId, startTime: startTime,
      duration: Duration(minutes: durationMinutes),
      frequency: ScheduleFrequency.values.firstWhere(
        (e) => e.name == frequency, orElse: () => ScheduleFrequency.daily),
      enabled: enabled,
    );
  }

  factory IrrigationScheduleModel.fromEntity(IrrigationScheduleEntity entity) {
    return IrrigationScheduleModel(
      id: entity.id, zoneId: entity.zoneId,
      startTime: entity.startTime,
      durationMinutes: entity.duration.inMinutes,
      frequency: entity.frequency.name, enabled: entity.enabled,
    );
  }
}
