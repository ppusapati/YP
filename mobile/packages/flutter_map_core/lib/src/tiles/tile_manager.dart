import 'dart:async';

import '../engine/map_controller_wrapper.dart';

/// Configuration for a tile source.
class TileSourceConfig {
  /// Unique identifier for the tile source.
  final String sourceId;

  /// Tile URL templates with `{z}`, `{x}`, `{y}` placeholders.
  ///
  /// Multiple URLs can be provided for load balancing across subdomains.
  /// Example: `['https://a.tiles.example.com/{z}/{x}/{y}.png',
  ///            'https://b.tiles.example.com/{z}/{x}/{y}.png']`
  final List<String> tileUrls;

  /// The size of each tile in pixels (typically 256 or 512).
  final int tileSize;

  /// Minimum zoom level for the source.
  final double minZoom;

  /// Maximum zoom level for the source.
  final double maxZoom;

  /// HTTP headers to include with tile requests (e.g., authorization).
  final Map<String, String> headers;

  /// Cache-control header value for tile caching behavior.
  final String? cacheControl;

  /// Optional attribution text.
  final String? attribution;

  /// Whether this source is a TMS (Tile Map Service) source.
  ///
  /// TMS uses inverted Y coordinates compared to XYZ (slippy map) tiles.
  final bool isTms;

  /// Creates a new [TileSourceConfig].
  const TileSourceConfig({
    required this.sourceId,
    required this.tileUrls,
    this.tileSize = 256,
    this.minZoom = 0,
    this.maxZoom = 22,
    this.headers = const {},
    this.cacheControl,
    this.attribution,
    this.isTms = false,
  });

  /// Returns the resolved tile URL for a given z/x/y coordinate.
  ///
  /// Selects from available URLs in round-robin fashion based on the
  /// hash of the tile coordinates.
  String resolveUrl(int z, int x, int y) {
    // Apply TMS Y-flip if needed.
    final tileY = isTms ? ((1 << z) - 1 - y) : y;

    final urlIndex = (x + tileY) % tileUrls.length;
    return tileUrls[urlIndex]
        .replaceAll('{z}', z.toString())
        .replaceAll('{x}', x.toString())
        .replaceAll('{y}', tileY.toString());
  }

  /// Creates a copy with updated fields.
  TileSourceConfig copyWith({
    String? sourceId,
    List<String>? tileUrls,
    int? tileSize,
    double? minZoom,
    double? maxZoom,
    Map<String, String>? headers,
    String? cacheControl,
    String? attribution,
    bool? isTms,
  }) {
    return TileSourceConfig(
      sourceId: sourceId ?? this.sourceId,
      tileUrls: tileUrls ?? this.tileUrls,
      tileSize: tileSize ?? this.tileSize,
      minZoom: minZoom ?? this.minZoom,
      maxZoom: maxZoom ?? this.maxZoom,
      headers: headers ?? this.headers,
      cacheControl: cacheControl ?? this.cacheControl,
      attribution: attribution ?? this.attribution,
      isTms: isTms ?? this.isTms,
    );
  }
}

/// Manages tile sources for the map engine.
///
/// [TileManager] provides a centralized registry for tile source
/// configurations and handles adding/removing tile sources and their
/// corresponding raster layers on the map.
class TileManager {
  final MapControllerWrapper _controller;

  /// Registry of tile source configurations by source ID.
  final Map<String, TileSourceConfig> _sources = {};

  /// Set of source IDs currently added to the map.
  final Set<String> _activeSources = {};

  /// Creates a new [TileManager].
  TileManager(this._controller);

  /// Returns all registered tile source configurations.
  Map<String, TileSourceConfig> get sources => Map.unmodifiable(_sources);

  /// Returns the set of currently active (added to map) source IDs.
  Set<String> get activeSources => Set.unmodifiable(_activeSources);

  /// Registers a tile source configuration.
  ///
  /// Does not add the source to the map. Call [activateSource] to do that.
  void registerSource(TileSourceConfig config) {
    _sources[config.sourceId] = config;
  }

  /// Unregisters a tile source configuration and removes it from the map
  /// if active.
  Future<void> unregisterSource(String sourceId) async {
    if (_activeSources.contains(sourceId)) {
      await deactivateSource(sourceId);
    }
    _sources.remove(sourceId);
  }

  /// Adds a registered tile source and its raster layer to the map.
  ///
  /// The layer ID is derived as `{sourceId}_layer`.
  Future<void> activateSource(
    String sourceId, {
    double opacity = 1.0,
    String? belowLayerId,
  }) async {
    final config = _sources[sourceId];
    if (config == null) {
      throw ArgumentError('No tile source registered with ID: $sourceId');
    }
    if (_activeSources.contains(sourceId)) return;

    await _controller.addRasterSource(
      sourceId,
      tiles: config.tileUrls,
      tileSize: config.tileSize,
      minZoom: config.minZoom,
      maxZoom: config.maxZoom,
    );

    await _controller.addRasterLayer(
      sourceId,
      _layerIdFor(sourceId),
      opacity: opacity,
      belowLayerId: belowLayerId,
    );

    _activeSources.add(sourceId);
  }

  /// Removes a tile source and its raster layer from the map.
  Future<void> deactivateSource(String sourceId) async {
    if (!_activeSources.contains(sourceId)) return;

    try {
      await _controller.removeLayer(_layerIdFor(sourceId));
      await _controller.removeSource(sourceId);
    } catch (_) {
      // Source/layer may already have been removed.
    }

    _activeSources.remove(sourceId);
  }

  /// Sets the visibility of an active tile layer.
  Future<void> setSourceVisibility(String sourceId, bool visible) async {
    if (!_activeSources.contains(sourceId)) return;
    await _controller.setLayerVisibility(_layerIdFor(sourceId), visible);
  }

  /// Removes all active tile sources from the map.
  Future<void> deactivateAll() async {
    for (final sourceId in Set<String>.from(_activeSources)) {
      await deactivateSource(sourceId);
    }
  }

  /// Returns whether a source is registered.
  bool hasSource(String sourceId) => _sources.containsKey(sourceId);

  /// Returns whether a source is currently active on the map.
  bool isSourceActive(String sourceId) => _activeSources.contains(sourceId);

  String _layerIdFor(String sourceId) => '${sourceId}_layer';
}
