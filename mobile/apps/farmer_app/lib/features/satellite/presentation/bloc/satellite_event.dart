import 'package:equatable/equatable.dart';

import '../../domain/entities/satellite_entity.dart';

sealed class SatelliteEvent extends Equatable {
  const SatelliteEvent();

  @override
  List<Object?> get props => [];
}

final class LoadSatelliteTiles extends SatelliteEvent {
  const LoadSatelliteTiles({
    required this.fieldId,
    this.layerType,
  });

  final String fieldId;
  final SatelliteLayerType? layerType;

  @override
  List<Object?> get props => [fieldId, layerType];
}

final class LoadNdviData extends SatelliteEvent {
  const LoadNdviData({
    required this.fieldId,
    required this.from,
    required this.to,
  });

  final String fieldId;
  final DateTime from;
  final DateTime to;

  @override
  List<Object?> get props => [fieldId, from, to];
}

final class LoadCropHealth extends SatelliteEvent {
  const LoadCropHealth({required this.fieldId});

  final String fieldId;

  @override
  List<Object?> get props => [fieldId];
}

final class SelectDateRange extends SatelliteEvent {
  const SelectDateRange({
    required this.from,
    required this.to,
  });

  final DateTime from;
  final DateTime to;

  @override
  List<Object?> get props => [from, to];
}
