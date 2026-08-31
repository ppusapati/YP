/// Defines the types of map layers supported by the agricultural GIS engine.
///
/// Each layer type corresponds to a specific kind of geospatial data
/// commonly used in precision agriculture workflows.
enum MapLayerType {
  /// Base map layer (streets, terrain, etc.).
  baseMap('base_map'),

  /// Satellite imagery layer.
  satellite('satellite'),

  /// Normalized Difference Vegetation Index overlay.
  ndvi('ndvi'),

  /// Farm boundary polygons.
  farmBoundary('farm_boundary'),

  /// Individual field boundary polygons.
  fieldBoundary('field_boundary'),

  /// Sensor device locations.
  sensorLocation('sensor_location'),

  /// Irrigation zone polygons.
  irrigationZone('irrigation_zone'),

  /// Drone-captured imagery overlay.
  droneImagery('drone_imagery'),

  /// Pest risk heat map or zone overlay.
  pestRisk('pest_risk'),

  /// Soil fertility data overlay.
  soilFertility('soil_fertility'),

  /// Task location markers.
  taskLocation('task_location'),

  /// Observation point markers (scouting notes, photos, etc.).
  observationPoint('observation_point');

  /// The string identifier used in source/layer IDs.
  final String value;

  const MapLayerType(this.value);

  /// Parses a [MapLayerType] from its string [value].
  ///
  /// Throws [ArgumentError] if the value does not match any type.
  static MapLayerType fromValue(String value) {
    return MapLayerType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => throw ArgumentError('Unknown MapLayerType: $value'),
    );
  }
}

/// Represents a single layer on the map with its configuration and state.
///
/// Layers are the primary mechanism for organizing and displaying
/// geospatial data on the map. Each layer has a unique [id], a [type]
/// that determines its rendering behavior, and various display properties.
class MapLayer {
  /// Unique identifier for this layer.
  final String id;

  /// The type of map layer, determining its rendering category.
  final MapLayerType type;

  /// Whether the layer is currently visible on the map.
  final bool visible;

  /// The opacity of the layer, from 0.0 (fully transparent) to 1.0 (fully opaque).
  final double opacity;

  /// The z-index controlling the stacking order of this layer.
  ///
  /// Higher values are rendered on top of lower values.
  final int zIndex;

  /// The identifier of the data source for this layer.
  ///
  /// This corresponds to a source ID registered with the map engine.
  final String? sourceId;

  /// The identifier of the style layer on the map.
  ///
  /// This may differ from [id] when multiple style layers are used for
  /// a single logical layer (e.g., a fill layer and an outline layer).
  final String? styleLayerId;

  /// Optional metadata associated with this layer.
  ///
  /// Can be used to store additional information such as data timestamps,
  /// color ramps, legend configuration, or filter criteria.
  final Map<String, dynamic> metadata;

  /// Creates a new [MapLayer] instance.
  const MapLayer({
    required this.id,
    required this.type,
    this.visible = true,
    this.opacity = 1.0,
    this.zIndex = 0,
    this.sourceId,
    this.styleLayerId,
    this.metadata = const {},
  });

  /// Creates a copy of this layer with the given fields replaced.
  MapLayer copyWith({
    String? id,
    MapLayerType? type,
    bool? visible,
    double? opacity,
    int? zIndex,
    String? sourceId,
    String? styleLayerId,
    Map<String, dynamic>? metadata,
  }) {
    return MapLayer(
      id: id ?? this.id,
      type: type ?? this.type,
      visible: visible ?? this.visible,
      opacity: opacity ?? this.opacity,
      zIndex: zIndex ?? this.zIndex,
      sourceId: sourceId ?? this.sourceId,
      styleLayerId: styleLayerId ?? this.styleLayerId,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() =>
      'MapLayer(id: $id, type: ${type.value}, visible: $visible, '
      'opacity: $opacity, zIndex: $zIndex)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MapLayer && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
