import 'package:equatable/equatable.dart';

enum SensorType {
  temperature,
  humidity,
  soilMoisture,
  light,
  windSpeed,
  rainfall,
  pressure,
}

enum SensorStatus {
  online,
  offline,
  lowBattery,
  error,
}

class Sensor extends Equatable {
  const Sensor({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.status,
    required this.lastReading,
    required this.batteryLevel,
  });

  final String id;
  final String name;
  final SensorType type;
  final SensorLocation location;
  final SensorStatus status;
  final double lastReading;
  final int batteryLevel;

  bool get isOnline => status == SensorStatus.online;
  bool get isBatteryLow => batteryLevel < 20;

  Sensor copyWith({
    String? id,
    String? name,
    SensorType? type,
    SensorLocation? location,
    SensorStatus? status,
    double? lastReading,
    int? batteryLevel,
  }) {
    return Sensor(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      location: location ?? this.location,
      status: status ?? this.status,
      lastReading: lastReading ?? this.lastReading,
      batteryLevel: batteryLevel ?? this.batteryLevel,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, type, location, status, lastReading, batteryLevel];
}

class SensorLocation extends Equatable {
  const SensorLocation({
    required this.latitude,
    required this.longitude,
    this.fieldId,
    this.fieldName,
  });

  final double latitude;
  final double longitude;
  final String? fieldId;
  final String? fieldName;

  @override
  List<Object?> get props => [latitude, longitude, fieldId, fieldName];
}
