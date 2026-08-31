import 'package:equatable/equatable.dart';

import '../../domain/entities/drone_layer_entity.dart';

sealed class DroneEvent extends Equatable {
  const DroneEvent();

  @override
  List<Object?> get props => [];
}

final class LoadDroneLayers extends DroneEvent {
  const LoadDroneLayers({required this.fieldId});
  final String fieldId;

  @override
  List<Object?> get props => [fieldId];
}

final class LoadFlights extends DroneEvent {
  const LoadFlights({required this.fieldId});
  final String fieldId;

  @override
  List<Object?> get props => [fieldId];
}

final class SelectLayer extends DroneEvent {
  const SelectLayer(this.layer);
  final DroneLayer layer;

  @override
  List<Object?> get props => [layer];
}

final class ToggleLayer extends DroneEvent {
  const ToggleLayer(this.layerType);
  final DroneLayerType layerType;

  @override
  List<Object?> get props => [layerType];
}

final class SelectFlight extends DroneEvent {
  const SelectFlight(this.flight);
  final DroneFlight flight;

  @override
  List<Object?> get props => [flight];
}
