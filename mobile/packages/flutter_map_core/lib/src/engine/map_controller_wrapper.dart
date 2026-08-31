import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:maplibre_gl/maplibre_gl.dart';

/// A wrapper around [MapLibreMapController] that provides a simplified and
/// consistent API for map operations.
///
/// This abstraction insulates the rest of the application from direct
/// dependency on the MapLibre controller, making it easier to test and
/// potentially swap map implementations.
class MapControllerWrapper {
  MapLibreMapController? _controller;

  /// Whether the underlying controller has been initialized.
  bool get isReady => _controller != null;

  /// The underlying MapLibre controller. Throws if not initialized.
  MapLibreMapController get controller {
    final c = _controller;
    if (c == null) {
      throw StateError(
        'MapControllerWrapper has not been initialized. '
        'Call attach() with a valid MapLibreMapController first.',
      );
    }
    return c;
  }

  /// Attaches a [MapLibreMapController] to this wrapper.
  ///
  /// This should be called once the map widget has been created and the
  /// controller is available (typically in onMapCreated or onStyleLoaded).
  void attach(MapLibreMapController controller) {
    _controller = controller;
  }

  /// Detaches the current controller, releasing resources.
  void detach() {
    _controller = null;
  }

  // ---------------------------------------------------------------------------
  // Camera operations
  // ---------------------------------------------------------------------------

  /// Animates the camera to a new position with an optional duration.
  ///
  /// Returns a [Future] that completes when the animation finishes.
  Future<void> animateCamera(
    CameraUpdate cameraUpdate, {
    Duration duration = const Duration(milliseconds: 500),
  }) async {
    if (!isReady) return;
    await controller.animateCamera(
      cameraUpdate,
      duration: duration,
    );
  }

  /// Immediately moves the camera to a new position without animation.
  Future<void> moveCamera(CameraUpdate cameraUpdate) async {
    if (!isReady) return;
    await controller.moveCamera(cameraUpdate);
  }

  /// Animates the camera to fit the given bounds with optional padding.
  Future<void> fitBounds(
    LatLngBounds bounds, {
    double padding = 50.0,
  }) async {
    if (!isReady) return;
    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        bounds,
        left: padding,
        top: padding,
        right: padding,
        bottom: padding,
      ),
    );
  }

  /// Returns the current zoom level.
  Future<double> getZoom() async {
    if (!isReady) return 0.0;
    return await controller.getZoom();
  }

  /// Returns the current camera target (center of the map).
  Future<LatLng> getCameraTarget() async {
    if (!isReady) return const LatLng(0, 0);
    final position = await controller.getCameraPosition();
    return position?.target ?? const LatLng(0, 0);
  }

  /// Returns the current camera position, if available.
  Future<CameraPosition?> getCameraPosition() async {
    if (!isReady) return null;
    return await controller.getCameraPosition();
  }

  // ---------------------------------------------------------------------------
  // Source operations
  // ---------------------------------------------------------------------------

  /// Adds a GeoJSON source to the map style.
  ///
  /// [sourceId] is a unique identifier for the source.
  /// [geoJson] is a Map representing valid GeoJSON data.
  Future<void> addGeoJsonSource(
    String sourceId,
    Map<String, dynamic> geoJson,
  ) async {
    if (!isReady) return;
    await controller.addSource(sourceId, GeojsonSourceProperties(data: geoJson));
  }

  /// Updates the data of an existing GeoJSON source.
  Future<void> setGeoJsonSource(
    String sourceId,
    Map<String, dynamic> geoJson,
  ) async {
    if (!isReady) return;
    await controller.setGeoJsonSource(sourceId, geoJson);
  }

  /// Adds a raster tile source to the map style.
  ///
  /// [sourceId] is a unique identifier for the source.
  /// [tiles] is a list of tile URL templates (with {z}/{x}/{y} placeholders).
  /// [tileSize] is the size of each tile in pixels (default 256).
  Future<void> addRasterSource(
    String sourceId, {
    required List<String> tiles,
    int tileSize = 256,
    double? minZoom,
    double? maxZoom,
  }) async {
    if (!isReady) return;
    await controller.addSource(
      sourceId,
      RasterSourceProperties(
        tiles: tiles,
        tileSize: tileSize,
        minzoom: minZoom,
        maxzoom: maxZoom,
      ),
    );
  }

  /// Removes a source from the map style.
  Future<void> removeSource(String sourceId) async {
    if (!isReady) return;
    await controller.removeSource(sourceId);
  }

  // ---------------------------------------------------------------------------
  // Layer operations
  // ---------------------------------------------------------------------------

  /// Adds a fill layer to the map style.
  Future<void> addFillLayer(
    String sourceId,
    String layerId, {
    Map<String, dynamic>? properties,
    String? belowLayerId,
  }) async {
    if (!isReady) return;
    await controller.addFillLayer(
      sourceId,
      layerId,
      FillLayerProperties(
        fillColor: properties?['fill-color'],
        fillOpacity: properties?['fill-opacity'],
        fillOutlineColor: properties?['fill-outline-color'],
      ),
      belowLayerId: belowLayerId,
    );
  }

  /// Adds a line layer to the map style.
  Future<void> addLineLayer(
    String sourceId,
    String layerId, {
    Map<String, dynamic>? properties,
    String? belowLayerId,
  }) async {
    if (!isReady) return;
    await controller.addLineLayer(
      sourceId,
      layerId,
      LineLayerProperties(
        lineColor: properties?['line-color'],
        lineWidth: properties?['line-width'],
        lineOpacity: properties?['line-opacity'],
        lineDasharray: properties?['line-dasharray'],
      ),
      belowLayerId: belowLayerId,
    );
  }

  /// Adds a circle layer to the map style.
  Future<void> addCircleLayer(
    String sourceId,
    String layerId, {
    Map<String, dynamic>? properties,
    String? belowLayerId,
  }) async {
    if (!isReady) return;
    await controller.addCircleLayer(
      sourceId,
      layerId,
      CircleLayerProperties(
        circleRadius: properties?['circle-radius'],
        circleColor: properties?['circle-color'],
        circleOpacity: properties?['circle-opacity'],
        circleStrokeWidth: properties?['circle-stroke-width'],
        circleStrokeColor: properties?['circle-stroke-color'],
      ),
      belowLayerId: belowLayerId,
    );
  }

  /// Adds a raster layer to the map style.
  Future<void> addRasterLayer(
    String sourceId,
    String layerId, {
    double? opacity,
    String? belowLayerId,
  }) async {
    if (!isReady) return;
    await controller.addRasterLayer(
      sourceId,
      layerId,
      RasterLayerProperties(
        rasterOpacity: opacity,
      ),
      belowLayerId: belowLayerId,
    );
  }

  /// Adds a symbol layer to the map style.
  Future<void> addSymbolLayer(
    String sourceId,
    String layerId, {
    Map<String, dynamic>? properties,
    String? belowLayerId,
  }) async {
    if (!isReady) return;
    await controller.addSymbolLayer(
      sourceId,
      layerId,
      SymbolLayerProperties(
        textField: properties?['text-field'],
        textSize: properties?['text-size'],
        textColor: properties?['text-color'],
        textHaloColor: properties?['text-halo-color'],
        textHaloWidth: properties?['text-halo-width'],
        iconImage: properties?['icon-image'],
        iconSize: properties?['icon-size'],
      ),
      belowLayerId: belowLayerId,
    );
  }

  /// Removes a layer from the map style.
  Future<void> removeLayer(String layerId) async {
    if (!isReady) return;
    await controller.removeLayer(layerId);
  }

  /// Sets the visibility of a layer.
  Future<void> setLayerVisibility(String layerId, bool visible) async {
    if (!isReady) return;
    await controller.setLayerVisibility(layerId, visible);
  }

  // ---------------------------------------------------------------------------
  // Query operations
  // ---------------------------------------------------------------------------

  /// Queries rendered features at a screen point.
  ///
  /// Returns a list of feature maps matching the optional [layerIds] and
  /// [filter] criteria.
  Future<List<dynamic>> queryRenderedFeatures(
    Point<num> point, {
    List<String>? layerIds,
    List<dynamic>? filter,
  }) async {
    if (!isReady) return [];
    return await controller.queryRenderedFeatures(
      point,
      layerIds ?? [],
      filter,
    );
  }

  /// Queries rendered features within a bounding box.
  Future<List<dynamic>> queryRenderedFeaturesInRect(
    Rect rect, {
    List<String>? layerIds,
    List<dynamic>? filter,
  }) async {
    if (!isReady) return [];
    return await controller.queryRenderedFeaturesInRect(
      rect,
      layerIds ?? [],
      filter,
    );
  }

  // ---------------------------------------------------------------------------
  // Coordinate conversion
  // ---------------------------------------------------------------------------

  /// Converts a geographic coordinate to a screen position.
  Future<Point<num>> toScreenLocation(LatLng latLng) async {
    return await controller.toScreenLocation(latLng);
  }

  /// Converts a screen position to a geographic coordinate.
  Future<LatLng> toLatLng(Point<num> screenLocation) async {
    return await controller.toLatLng(screenLocation);
  }

  // ---------------------------------------------------------------------------
  // Symbol / Marker operations
  // ---------------------------------------------------------------------------

  /// Adds a symbol (marker) to the map.
  Future<Symbol> addSymbol(SymbolOptions options) async {
    return await controller.addSymbol(options);
  }

  /// Removes a symbol from the map.
  Future<void> removeSymbol(Symbol symbol) async {
    if (!isReady) return;
    await controller.removeSymbol(symbol);
  }

  /// Updates an existing symbol's options.
  Future<void> updateSymbol(Symbol symbol, SymbolOptions changes) async {
    if (!isReady) return;
    await controller.updateSymbol(symbol, changes);
  }

  /// Removes all symbols from the map.
  Future<void> clearSymbols() async {
    if (!isReady) return;
    await controller.clearSymbols();
  }

  // ---------------------------------------------------------------------------
  // Line operations
  // ---------------------------------------------------------------------------

  /// Adds a line to the map.
  Future<Line> addLine(LineOptions options) async {
    return await controller.addLine(options);
  }

  /// Removes a line from the map.
  Future<void> removeLine(Line line) async {
    if (!isReady) return;
    await controller.removeLine(line);
  }

  /// Updates an existing line's options.
  Future<void> updateLine(Line line, LineOptions changes) async {
    if (!isReady) return;
    await controller.updateLine(line, changes);
  }

  /// Removes all lines from the map.
  Future<void> clearLines() async {
    if (!isReady) return;
    await controller.clearLines();
  }

  // ---------------------------------------------------------------------------
  // Fill operations
  // ---------------------------------------------------------------------------

  /// Adds a fill (polygon) to the map.
  Future<Fill> addFill(FillOptions options) async {
    return await controller.addFill(options);
  }

  /// Removes a fill from the map.
  Future<void> removeFill(Fill fill) async {
    if (!isReady) return;
    await controller.removeFill(fill);
  }

  /// Removes all fills from the map.
  Future<void> clearFills() async {
    if (!isReady) return;
    await controller.clearFills();
  }

  // ---------------------------------------------------------------------------
  // Circle operations
  // ---------------------------------------------------------------------------

  /// Adds a circle to the map.
  Future<Circle> addCircle(CircleOptions options) async {
    return await controller.addCircle(options);
  }

  /// Removes a circle from the map.
  Future<void> removeCircle(Circle circle) async {
    if (!isReady) return;
    await controller.removeCircle(circle);
  }

  /// Removes all circles from the map.
  Future<void> clearCircles() async {
    if (!isReady) return;
    await controller.clearCircles();
  }
}
