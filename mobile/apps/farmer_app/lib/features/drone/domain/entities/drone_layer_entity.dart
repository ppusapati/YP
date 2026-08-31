import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

/// The type of drone imagery layer.
enum DroneLayerType {
  orthomosaic,
  ndvi,
  plantDensity;

  String get displayName {
    switch (this) {
      case DroneLayerType.orthomosaic:
        return 'Orthomosaic';
      case DroneLayerType.ndvi:
        return 'NDVI';
      case DroneLayerType.plantDensity:
        return 'Plant Density';
    }
  }

  String get description {
    switch (this) {
      case DroneLayerType.orthomosaic:
        return 'High-resolution composite image';
      case DroneLayerType.ndvi:
        return 'Normalized Difference Vegetation Index';
      case DroneLayerType.plantDensity:
        return 'Plant count and spacing analysis';
    }
  }
}

/// Represents a processed drone imagery layer for map overlay.
class DroneLayer extends Equatable {
  final String id;
  final String fieldId;
  final DroneLayerType layerType;
  final String tileUrl;
  final DateTime captureDate;
  final double resolution;
  final DroneLayerBounds bounds;

  const DroneLayer({
    required this.id,
    required this.fieldId,
    required this.layerType,
    required this.tileUrl,
    required this.captureDate,
    required this.resolution,
    required this.bounds,
  });

  DroneLayer copyWith({
    String? id,
    String? fieldId,
    DroneLayerType? layerType,
    String? tileUrl,
    DateTime? captureDate,
    double? resolution,
    DroneLayerBounds? bounds,
  }) {
    return DroneLayer(
      id: id ?? this.id,
      fieldId: fieldId ?? this.fieldId,
      layerType: layerType ?? this.layerType,
      tileUrl: tileUrl ?? this.tileUrl,
      captureDate: captureDate ?? this.captureDate,
      resolution: resolution ?? this.resolution,
      bounds: bounds ?? this.bounds,
    );
  }

  @override
  List<Object?> get props => [
        id,
        fieldId,
        layerType,
        tileUrl,
        captureDate,
        resolution,
        bounds,
      ];

  @override
  String toString() => 'DroneLayer(id: $id, type: ${layerType.displayName}, '
      'date: $captureDate)';
}

/// Bounding box for a drone layer.
class DroneLayerBounds extends Equatable {
  final LatLng southwest;
  final LatLng northeast;

  const DroneLayerBounds({
    required this.southwest,
    required this.northeast,
  });

  @override
  List<Object?> get props => [southwest, northeast];
}

/// Represents a drone flight mission.
class DroneFlight extends Equatable {
  final String id;
  final String fieldId;
  final DateTime flightDate;
  final List<DroneLayer> layers;
  final double altitudeMeters;
  final double coverageHectares;

  const DroneFlight({
    required this.id,
    required this.fieldId,
    required this.flightDate,
    this.layers = const [],
    required this.altitudeMeters,
    required this.coverageHectares,
  });

  @override
  List<Object?> get props => [
        id,
        fieldId,
        flightDate,
        layers,
        altitudeMeters,
        coverageHectares,
      ];
}
