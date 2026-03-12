import '../engine/map_controller_wrapper.dart';

/// Configuration for a raster tile layer.
///
/// Raster layers display pre-rendered tile images (satellite imagery,
/// NDVI overlays, drone orthomosaics, etc.) from a tile server
/// using TMS or XYZ URL templates.
class RasterLayer {
  /// Unique identifier for this layer.
  final String layerId;

  /// The source identifier on the map.
  final String sourceId;

  /// Tile URL templates with {z}/{x}/{y} placeholders.
  ///
  /// Multiple URLs can be provided for load balancing across subdomains.
  /// Example: `['https://tiles.example.com/{z}/{x}/{y}.png']`
  final List<String> tileUrls;

  /// The size of tiles in pixels (typically 256 or 512).
  final int tileSize;

  /// The opacity of the raster layer (0.0 to 1.0).
  final double opacity;

  /// Minimum zoom level for the tile source.
  final double? minZoom;

  /// Maximum zoom level for the tile source.
  final double? maxZoom;

  /// Optional layer ID below which this layer should be inserted.
  final String? belowLayerId;

  /// Attribution text for the tile source.
  final String? attribution;

  /// Whether the layer is currently added to the map.
  bool _isAdded = false;

  /// Creates a new [RasterLayer].
  RasterLayer({
    required this.layerId,
    required this.tileUrls,
    String? sourceId,
    this.tileSize = 256,
    this.opacity = 1.0,
    this.minZoom,
    this.maxZoom,
    this.belowLayerId,
    this.attribution,
  }) : sourceId = sourceId ?? '${layerId}_source';

  /// Whether this layer has been added to the map.
  bool get isAdded => _isAdded;

  /// Adds the raster source and layer to the map.
  Future<void> addToMap(MapControllerWrapper controller) async {
    if (_isAdded) return;

    await controller.addRasterSource(
      sourceId,
      tiles: tileUrls,
      tileSize: tileSize,
      minZoom: minZoom,
      maxZoom: maxZoom,
    );

    await controller.addRasterLayer(
      sourceId,
      layerId,
      opacity: opacity,
      belowLayerId: belowLayerId,
    );

    _isAdded = true;
  }

  /// Removes this layer and its source from the map.
  Future<void> removeFromMap(MapControllerWrapper controller) async {
    if (!_isAdded) return;

    await controller.removeLayer(layerId);
    await controller.removeSource(sourceId);
    _isAdded = false;
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
  // Factory constructors for common raster layer types
  // ---------------------------------------------------------------------------

  /// Creates a satellite imagery raster layer.
  factory RasterLayer.satellite({
    required List<String> tileUrls,
    String layerId = 'satellite_layer',
    double opacity = 1.0,
    String? belowLayerId,
  }) {
    return RasterLayer(
      layerId: layerId,
      tileUrls: tileUrls,
      tileSize: 256,
      opacity: opacity,
      minZoom: 0,
      maxZoom: 22,
      belowLayerId: belowLayerId,
    );
  }

  /// Creates an NDVI overlay raster layer.
  factory RasterLayer.ndviOverlay({
    required List<String> tileUrls,
    String layerId = 'ndvi_layer',
    double opacity = 0.7,
    String? belowLayerId,
  }) {
    return RasterLayer(
      layerId: layerId,
      tileUrls: tileUrls,
      tileSize: 256,
      opacity: opacity,
      minZoom: 10,
      maxZoom: 20,
      belowLayerId: belowLayerId,
    );
  }

  /// Creates a drone imagery overlay raster layer.
  factory RasterLayer.droneImagery({
    required List<String> tileUrls,
    String layerId = 'drone_imagery_layer',
    double opacity = 1.0,
    int tileSize = 512,
    String? belowLayerId,
  }) {
    return RasterLayer(
      layerId: layerId,
      tileUrls: tileUrls,
      tileSize: tileSize,
      opacity: opacity,
      minZoom: 14,
      maxZoom: 22,
      belowLayerId: belowLayerId,
    );
  }
}
