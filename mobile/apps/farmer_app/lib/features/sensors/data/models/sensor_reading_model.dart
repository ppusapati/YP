import '../../domain/entities/sensor_entity.dart';
import '../../domain/entities/sensor_reading_entity.dart';

class SensorReadingModel extends SensorReading {
  const SensorReadingModel({
    required super.sensorId,
    required super.type,
    required super.value,
    required super.unit,
    required super.timestamp,
  });

  factory SensorReadingModel.fromJson(Map<String, dynamic> json) {
    return SensorReadingModel(
      sensorId: json['sensor_id'] as String,
      type: SensorType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SensorType.temperature,
      ),
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  factory SensorReadingModel.fromEntity(SensorReading entity) {
    return SensorReadingModel(
      sensorId: entity.sensorId,
      type: entity.type,
      value: entity.value,
      unit: entity.unit,
      timestamp: entity.timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sensor_id': sensorId,
      'type': type.name,
      'value': value,
      'unit': unit,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
