import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import 'map_config.dart';
import 'map_controller_wrapper.dart';

/// Callback signature invoked when the map is fully loaded and ready.
typedef MapReadyCallback = void Function(MapControllerWrapper controller);

/// Core map engine that initializes and manages the MapLibre map lifecycle.
///
/// [MapEngine] is the central orchestrator for map rendering. It creates
/// the map widget, manages the controller lifecycle, and provides the
/// [MapControllerWrapper] to other components.
///
/// Usage:
/// ```dart
/// final engine = MapEngine(
///   config: MapConfig(
///     styleUrl: 'https://demotiles.maplibre.org/style.json',
///     initialCenter: LatLng(-33.8688, 151.2093),
///     initialZoom: 12.0,
///   ),
/// );
///
/// // In your widget tree:
/// engine.buildMapWidget(
///   onMapReady: (controller) {
///     // Map is ready to use.
///   },
/// );
/// ```
class MapEngine {
  /// The configuration used to initialize the map.
  final MapConfig config;

  /// The wrapper around the MapLibre controller.
  final MapControllerWrapper controllerWrapper = MapControllerWrapper();

  final List<MapReadyCallback> _onReadyCallbacks = [];
  final Completer<MapControllerWrapper> _readyCompleter = Completer();

  bool _disposed = false;

  /// Creates a new [MapEngine] with the given [config].
  MapEngine({required this.config});

  /// A future that completes when the map controller is ready.
  Future<MapControllerWrapper> get ready => _readyCompleter.future;

  /// Whether the map engine has been disposed.
  bool get isDisposed => _disposed;

  /// Whether the map controller is attached and ready.
  bool get isReady => controllerWrapper.isReady;

  /// Registers a callback to be invoked when the map is ready.
  ///
  /// If the map is already ready, the callback is invoked immediately.
  void onMapReady(MapReadyCallback callback) {
    if (controllerWrapper.isReady) {
      callback(controllerWrapper);
    } else {
      _onReadyCallbacks.add(callback);
    }
  }

  /// Builds the MapLibre map widget with the configured settings.
  ///
  /// [onMapReady] is called once the map style has loaded and the controller
  /// is available. [onCameraIdle] is called when the camera stops moving.
  /// [onMapClick] and [onMapLongClick] handle tap interactions.
  Widget buildMapWidget({
    MapReadyCallback? onMapReady,
    VoidCallback? onCameraIdle,
    void Function(Point<num>, LatLng)? onMapClick,
    void Function(Point<num>, LatLng)? onMapLongClick,
  }) {
    if (onMapReady != null) {
      this.onMapReady(onMapReady);
    }

    return MapLibreMap(
      styleString: config.styleUrl,
      initialCameraPosition: CameraPosition(
        target: config.initialCenter,
        zoom: config.initialZoom,
      ),
      minMaxZoomPreference: MinMaxZoomPreference(config.minZoom, config.maxZoom),
      myLocationEnabled: config.myLocationEnabled,
      compassEnabled: config.compassEnabled,
      rotateGesturesEnabled: config.rotateGesturesEnabled,
      tiltGesturesEnabled: config.tiltGesturesEnabled,
      zoomGesturesEnabled: config.zoomGesturesEnabled,
      scrollGesturesEnabled: config.scrollGesturesEnabled,
      onMapCreated: _onMapCreated,
      onStyleLoadedCallback: _onStyleLoaded,
      onCameraIdle: onCameraIdle,
      onMapClick: onMapClick,
      onMapLongClick: onMapLongClick,
    );
  }

  void _onMapCreated(MapLibreMapController controller) {
    controllerWrapper.attach(controller);
  }

  void _onStyleLoaded() {
    if (!_readyCompleter.isCompleted) {
      _readyCompleter.complete(controllerWrapper);
    }

    for (final callback in _onReadyCallbacks) {
      callback(controllerWrapper);
    }
    _onReadyCallbacks.clear();

    // If bounds are configured, fit to them after loading.
    if (config.bounds != null) {
      controllerWrapper.fitBounds(config.bounds!);
    }
  }

  /// Disposes of the map engine and releases resources.
  ///
  /// After calling this, the engine should not be used.
  void dispose() {
    _disposed = true;
    _onReadyCallbacks.clear();
    controllerWrapper.detach();
  }
}
