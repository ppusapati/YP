import 'package:equatable/equatable.dart';

sealed class SensorEvent extends Equatable {
  const SensorEvent();
  @override
  List<Object?> get props => [];
}

final class LoadSensorReadings extends SensorEvent {
  const LoadSensorReadings({required this.fieldId});
  final String fieldId;
  @override
  List<Object?> get props => [fieldId];
}
