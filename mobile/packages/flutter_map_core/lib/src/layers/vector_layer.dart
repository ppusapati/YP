import '../engine/map_controller_wrapper.dart';
import 'geojson_source.dart';

/// The visual style type for a vector layer.
enum VectorLayerStyle {
  /// A filled polygon layer.
  fill,

  /// A stroked line layer.
  line,

  /// A circle/point layer.
  circle,

  /// A text/icon symbol layer.
  symbol,
}

/// Configuration for rendering a vector layer backed by a GeoJSON source.
///
/// Vector layers display geographic features (polygons, lines, points)
/// with configurable visual properties. They are used for farm boundaries,
/// field boundaries, sensor locations, task markers, and other discrete
/// geospatial data.
class VectorLayer {
  /// Unique identifier for this layer.
  final String layerId;

  /// The GeoJSON source providing data for this layer.
  final GeoJsonSource source;

  /// The visual style type for rendering.
  final VectorLayerStyle style;

  /// Style properties passed to the MapLibre layer.
  ///
  /// Keys are MapLibre style property names (e.g., 'fill-color', 'line-width').
  final Map<String, dynamic> properties;

  /// Optional layer ID below which this layer should be inserted.
  final String? belowLayerId;

  /// Whether the layer is currently added to the map.
  bool _isAdded = false;

  /// Creates a new [VectorLayer].
  VectorLayer({
    required this.layerId,
    required this.source,
    required this.style,
    this.properties = const {},
    this.belowLayerId,
  });

  /// Whether this layer has been added to the map.
  bool get isAdded => _isAdded;

  /// Adds the source and layer to the map.
  ///
  /// The source is added first if it has not already been added, then
  /// the style layer is created on top.
  Future<void> addToMap(MapControllerWrapper controller) async {
    if (_isAdded) return;

    // Ensure source is on the map.
    if (!source.isAdded) {
      await source.addToMap(controller);
    }

    switch (style) {
      case VectorLayerStyle.fill:
        await controller.addFillLayer(
          source.sourceId,
          layerId,
          properties: properties,
          belowLayerId: belowLayerId,
        );
        break;
      case VectorLayerStyle.line:
        await controller.addLineLayer(
          source.sourceId,
          layerId,
          properties: properties,
          belowLayerId: belowLayerId,
        );
        break;
      case VectorLayerStyle.circle:
        await controller.addCircleLayer(
          source.sourceId,
          layerId,
          properties: properties,
          belowLayerId: belowLayerId,
        );
        break;
      case VectorLayerStyle.symbol:
        await controller.addSymbolLayer(
          source.sourceId,
          layerId,
          properties: properties,
          belowLayerId: belowLayerId,
        );
        break;
    }

    _isAdded = true;
  }

  /// Removes this layer and optionally its source from the map.
  Future<void> removeFromMap(
    MapControllerWrapper controller, {
    bool removeSource = false,
  }) async {
    if (!_isAdded) return;

    await controller.removeLayer(layerId);
    _isAdded = false;

    if (removeSource && source.isAdded) {
      await source.removeFromMap(controller);
    }
  }

  /// Updates the GeoJSON data of the underlying source.
  Future<void> updateData(
    MapControllerWrapper controller,
    Map<String, dynamic> geoJson,
  ) async {
    await source.update(controller, geoJson);
  }

  /// Sets the visibility of this layer.
  Future<void> setVisible(
    MapControllerWrapper controller,
    bool visible,
  ) async {
    if (!_isAdded) return;
    await controller.setLayerVisibility(layerId, visible);
  }

  // ---------------------------------------------------------------------------
  // Factory constructors for common agricultural layer patterns
  // ---------------------------------------------------------------------------

  /// Creates a polygon fill layer suitable for farm/field boundaries.
  factory VectorLayer.boundaryFill({
    required String layerId,
    required GeoJsonSource source,
    String fillColor = '#4CAF50',
    double fillOpacity = 0.2,
    String outlineColor = '#2E7D32',
    String? belowLayerId,
  }) {
    return VectorLayer(
      layerId: layerId,
      source: source,
      style: VectorLayerStyle.fill,
      properties: {
        'fill-color': fillColor,
        'fill-opacity': fillOpacity,
        'fill-outline-color': outlineColor,
      },
      belowLayerId: belowLayerId,
    );
  }

  /// Creates a line layer suitable for boundary outlines.
  factory VectorLayer.boundaryOutline({
    required String layerId,
    required GeoJsonSource source,
    String lineColor = '#2E7D32',
    double lineWidth = 2.0,
    double lineOpacity = 1.0,
    String? belowLayerId,
  }) {
    return VectorLayer(
      layerId: layerId,
      source: source,
      style: VectorLayerStyle.line,
      properties: {
        'line-color': lineColor,
        'line-width': lineWidth,
        'line-opacity': lineOpacity,
      },
      belowLayerId: belowLayerId,
    );
  }

  /// Creates a circle layer suitable for sensor or observation points.
  factory VectorLayer.pointMarkers({
    required String layerId,
    required GeoJsonSource source,
    String circleColor = '#FF5722',
    double circleRadius = 6.0,
    String strokeColor = '#FFFFFF',
    double strokeWidth = 2.0,
    String? belowLayerId,
  }) {
    return VectorLayer(
      layerId: layerId,
      source: source,
      style: VectorLayerStyle.circle,
      properties: {
        'circle-color': circleColor,
        'circle-radius': circleRadius,
        'circle-stroke-color': strokeColor,
        'circle-stroke-width': strokeWidth,
      },
      belowLayerId: belowLayerId,
    );
  }

  /// Creates a symbol layer for labeled markers.
  factory VectorLayer.labeledPoints({
    required String layerId,
    required GeoJsonSource source,
    String textField = 'name',
    double textSize = 12.0,
    String textColor = '#333333',
    String? iconImage,
    String? belowLayerId,
  }) {
    return VectorLayer(
      layerId: layerId,
      source: source,
      style: VectorLayerStyle.symbol,
      properties: {
        'text-field': ['get', textField],
        'text-size': textSize,
        'text-color': textColor,
        'text-halo-color': '#FFFFFF',
        'text-halo-width': 1.0,
        if (iconImage != null) 'icon-image': iconImage,
      },
      belowLayerId: belowLayerId,
    );
  }
}
