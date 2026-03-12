import 'package:equatable/equatable.dart';

import 'sensor_entity.dart';

class SensorReading extends Equatable {
  const SensorReading({
    required this.sensorId,
    required this.type,
    required this.value,
    required this.unit,
    required this.timestamp,
  });

  final String sensorId;
  final SensorType type;
  final double value;
  final String unit;
  final DateTime timestamp;

  @override
  List<Object?> get props => [sensorId, type, value, unit, timestamp];
}
