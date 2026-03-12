import 'package:equatable/equatable.dart';

import '../../domain/entities/drone_layer_entity.dart';

sealed class DroneState extends Equatable {
  const DroneState();

  @override
  List<Object?> get props => [];
}

final class DroneInitial extends DroneState {
  const DroneInitial();
}

final class DroneLoading extends DroneState {
  const DroneLoading();
}

final class DroneLayersLoaded extends DroneState {
  const DroneLayersLoaded({
    required this.layers,
    required this.flights,
    this.selectedFlight,
    this.activeLayerTypes = const {},
    this.selectedLayer,
  });

  final List<DroneLayer> layers;
  final List<DroneFlight> flights;
  final DroneFlight? selectedFlight;
  final Set<DroneLayerType> activeLayerTypes;
  final DroneLayer? selectedLayer;

  List<DroneLayer> get visibleLayers =>
      layers.where((l) => activeLayerTypes.contains(l.layerType)).toList();

  DroneLayersLoaded copyWith({
    List<DroneLayer>? layers,
    List<DroneFlight>? flights,
    DroneFlight? Function()? selectedFlight,
    Set<DroneLayerType>? activeLayerTypes,
    DroneLayer? Function()? selectedLayer,
  }) {
    return DroneLayersLoaded(
      layers: layers ?? this.layers,
      flights: flights ?? this.flights,
      selectedFlight:
          selectedFlight != null ? selectedFlight() : this.selectedFlight,
      activeLayerTypes: activeLayerTypes ?? this.activeLayerTypes,
      selectedLayer:
          selectedLayer != null ? selectedLayer() : this.selectedLayer,
    );
  }

  @override
  List<Object?> get props => [
        layers,
        flights,
        selectedFlight,
        activeLayerTypes,
        selectedLayer,
      ];
}

final class DroneError extends DroneState {
  const DroneError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
