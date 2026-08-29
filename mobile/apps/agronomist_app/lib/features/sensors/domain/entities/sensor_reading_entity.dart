import 'package:equatable/equatable.dart';

enum SensorType { temperature, humidity, soilMoisture, light, windSpeed, rainfall }

class SensorReadingEntity extends Equatable {
  final String id;
  final String fieldId;
  final SensorType type;
  final double value;
  final String unit;
  final String sensorName;
  final DateTime readAt;
  final bool isOnline;

  const SensorReadingEntity({
    required this.id,
    required this.fieldId,
    required this.type,
    required this.value,
    required this.unit,
    required this.sensorName,
    required this.readAt,
    this.isOnline = true,
  });

  @override
  List<Object?> get props => [id, fieldId, type, value, unit, sensorName, readAt, isOnline];
}
