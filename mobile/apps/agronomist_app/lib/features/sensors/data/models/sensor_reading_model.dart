import '../../domain/entities/sensor_reading_entity.dart';

class SensorReadingModel {
  final String id;
  final String fieldId;
  final String type;
  final double value;
  final String unit;
  final String sensorName;
  final DateTime readAt;
  final bool isOnline;

  const SensorReadingModel({
    required this.id, required this.fieldId, required this.type,
    required this.value, required this.unit, required this.sensorName,
    required this.readAt, this.isOnline = true,
  });

  factory SensorReadingModel.fromJson(Map<String, dynamic> json) {
    return SensorReadingModel(
      id: json['id'] as String,
      fieldId: json['field_id'] as String,
      type: json['type'] as String? ?? 'temperature',
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] as String? ?? '',
      sensorName: json['sensor_name'] as String? ?? '',
      readAt: DateTime.parse(json['read_at'] as String),
      isOnline: json['is_online'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'field_id': fieldId, 'type': type,
    'value': value, 'unit': unit, 'sensor_name': sensorName,
    'read_at': readAt.toIso8601String(), 'is_online': isOnline,
  };

  SensorReadingEntity toEntity() {
    return SensorReadingEntity(
      id: id, fieldId: fieldId,
      type: SensorType.values.firstWhere((e) => e.name == type, orElse: () => SensorType.temperature),
      value: value, unit: unit, sensorName: sensorName,
      readAt: readAt, isOnline: isOnline,
    );
  }
}
