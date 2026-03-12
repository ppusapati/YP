import 'package:latlong2/latlong.dart';

import '../../domain/entities/drone_layer_entity.dart';

class DroneLayerModel extends DroneLayer {
  const DroneLayerModel({
    required super.id,
    required super.fieldId,
    required super.layerType,
    required super.tileUrl,
    required super.captureDate,
    required super.resolution,
    required super.bounds,
  });

  factory DroneLayerModel.fromJson(Map<String, dynamic> json) {
    final boundsJson = json['bounds'] as Map<String, dynamic>;
    final sw = boundsJson['southwest'] as Map<String, dynamic>;
    final ne = boundsJson['northeast'] as Map<String, dynamic>;

    return DroneLayerModel(
      id: json['id'] as String,
      fieldId: json['field_id'] as String,
      layerType: DroneLayerType.values.firstWhere(
        (e) => e.name == json['layer_type'],
        orElse: () => DroneLayerType.orthomosaic,
      ),
      tileUrl: json['tile_url'] as String,
      captureDate: DateTime.parse(json['capture_date'] as String),
      resolution: (json['resolution'] as num).toDouble(),
      bounds: DroneLayerBounds(
        southwest: LatLng(
          (sw['lat'] as num).toDouble(),
          (sw['lng'] as num).toDouble(),
        ),
        northeast: LatLng(
          (ne['lat'] as num).toDouble(),
          (ne['lng'] as num).toDouble(),
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'field_id': fieldId,
      'layer_type': layerType.name,
      'tile_url': tileUrl,
      'capture_date': captureDate.toIso8601String(),
      'resolution': resolution,
      'bounds': {
        'southwest': {
          'lat': bounds.southwest.latitude,
          'lng': bounds.southwest.longitude,
        },
        'northeast': {
          'lat': bounds.northeast.latitude,
          'lng': bounds.northeast.longitude,
        },
      },
    };
  }
}

class DroneFlightModel extends DroneFlight {
  const DroneFlightModel({
    required super.id,
    required super.fieldId,
    required super.flightDate,
    super.layers,
    required super.altitudeMeters,
    required super.coverageHectares,
  });

  factory DroneFlightModel.fromJson(Map<String, dynamic> json) {
    final layersList = json['layers'] as List<dynamic>? ?? [];
    return DroneFlightModel(
      id: json['id'] as String,
      fieldId: json['field_id'] as String,
      flightDate: DateTime.parse(json['flight_date'] as String),
      layers: layersList
          .map((e) => DroneLayerModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      altitudeMeters: (json['altitude_meters'] as num).toDouble(),
      coverageHectares: (json['coverage_hectares'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'field_id': fieldId,
      'flight_date': flightDate.toIso8601String(),
      'altitude_meters': altitudeMeters,
      'coverage_hectares': coverageHectares,
    };
  }
}
