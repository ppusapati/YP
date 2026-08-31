import '../../domain/entities/sensor_entity.dart';

class SensorLocationModel extends SensorLocation {
  const SensorLocationModel({
    required super.latitude,
    required super.longitude,
    super.fieldId,
    super.fieldName,
  });

  factory SensorLocationModel.fromJson(Map<String, dynamic> json) {
    return SensorLocationModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      fieldId: json['field_id'] as String?,
      fieldName: json['field_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'field_id': fieldId,
      'field_name': fieldName,
    };
  }
}

class SensorModel extends Sensor {
  const SensorModel({
    required super.id,
    required super.name,
    required super.type,
    required super.location,
    required super.status,
    required super.lastReading,
    required super.batteryLevel,
  });

  factory SensorModel.fromJson(Map<String, dynamic> json) {
    return SensorModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: _parseSensorType(json['type'] as String),
      location: SensorLocationModel.fromJson(
        json['location'] as Map<String, dynamic>,
      ),
      status: _parseSensorStatus(json['status'] as String),
      lastReading: (json['last_reading'] as num).toDouble(),
      batteryLevel: json['battery_level'] as int,
    );
  }

  factory SensorModel.fromEntity(Sensor entity) {
    return SensorModel(
      id: entity.id,
      name: entity.name,
      type: entity.type,
      location: entity.location,
      status: entity.status,
      lastReading: entity.lastReading,
      batteryLevel: entity.batteryLevel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'location': {
        'latitude': location.latitude,
        'longitude': location.longitude,
        'field_id': location.fieldId,
        'field_name': location.fieldName,
      },
      'status': status.name,
      'last_reading': lastReading,
      'battery_level': batteryLevel,
    };
  }

  static SensorType _parseSensorType(String type) {
    return SensorType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => SensorType.temperature,
    );
  }

  static SensorStatus _parseSensorStatus(String status) {
    return SensorStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => SensorStatus.offline,
    );
  }
}
