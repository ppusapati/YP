import 'package:equatable/equatable.dart';

import '../../domain/entities/sensor_entity.dart';

sealed class SensorEvent extends Equatable {
  const SensorEvent();

  @override
  List<Object?> get props => [];
}

final class LoadSensors extends SensorEvent {
  const LoadSensors();
}

final class LoadReadings extends SensorEvent {
  const LoadReadings({
    required this.sensorId,
    this.from,
    this.to,
  });

  final String sensorId;
  final DateTime? from;
  final DateTime? to;

  @override
  List<Object?> get props => [sensorId, from, to];
}

final class RefreshSensor extends SensorEvent {
  const RefreshSensor({required this.sensorId});

  final String sensorId;

  @override
  List<Object?> get props => [sensorId];
}

final class SelectSensor extends SensorEvent {
  const SelectSensor({required this.sensorId});

  final String sensorId;

  @override
  List<Object?> get props => [sensorId];
}

final class FilterByType extends SensorEvent {
  const FilterByType({this.type});

  final SensorType? type;

  @override
  List<Object?> get props => [type];
}
