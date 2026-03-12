import 'package:equatable/equatable.dart';

import '../../domain/entities/crop_health_entity.dart';
import '../../domain/entities/satellite_entity.dart';

sealed class SatelliteState extends Equatable {
  const SatelliteState();

  @override
  List<Object?> get props => [];
}

final class SatelliteInitial extends SatelliteState {
  const SatelliteInitial();
}

final class SatelliteLoading extends SatelliteState {
  const SatelliteLoading();
}

final class SatelliteTilesLoaded extends SatelliteState {
  const SatelliteTilesLoaded({required this.tiles});

  final List<SatelliteTile> tiles;

  @override
  List<Object?> get props => [tiles];
}

final class NdviDataLoaded extends SatelliteState {
  const NdviDataLoaded({
    required this.dataPoints,
    required this.from,
    required this.to,
  });

  final List<NdviDataPoint> dataPoints;
  final DateTime from;
  final DateTime to;

  @override
  List<Object?> get props => [dataPoints, from, to];
}

final class CropHealthLoaded extends SatelliteState {
  const CropHealthLoaded({required this.cropHealth});

  final CropHealthEntity cropHealth;

  @override
  List<Object?> get props => [cropHealth];
}

final class SatelliteDateRangeSelected extends SatelliteState {
  const SatelliteDateRangeSelected({
    required this.from,
    required this.to,
  });

  final DateTime from;
  final DateTime to;

  @override
  List<Object?> get props => [from, to];
}

final class SatelliteError extends SatelliteState {
  const SatelliteError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
