import 'package:equatable/equatable.dart';

import '../../domain/entities/sensor_reading_entity.dart';

sealed class SensorState extends Equatable {
  const SensorState();
  @override
  List<Object?> get props => [];
}

final class SensorInitial extends SensorState { const SensorInitial(); }
final class SensorLoading extends SensorState { const SensorLoading(); }

final class SensorReadingsLoaded extends SensorState {
  const SensorReadingsLoaded({required this.readings});
  final List<SensorReadingEntity> readings;
  @override
  List<Object?> get props => [readings];
}

final class SensorError extends SensorState {
  const SensorError({required this.message});
  final String message;
  @override
  List<Object?> get props => [message];
}
