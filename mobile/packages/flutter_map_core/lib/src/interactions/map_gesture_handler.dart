import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../engine/map_controller_wrapper.dart';

/// The type of map gesture event.
enum MapGestureType {
  /// A single tap on the map.
  tap,

  /// A long press on the map.
  longPress,

  /// A pan/drag gesture.
  pan,

  /// A pinch zoom gesture.
  pinchZoom,
}

/// Represents a gesture event on the map, including its geographic and
/// screen coordinates.
class MapGestureEvent {
  /// The type of gesture.
  final MapGestureType type;

  /// The geographic coordinate of the gesture.
  final LatLng latLng;

  /// The screen position of the gesture.
  final Point<num> screenPoint;

  /// Features found at the gesture location (populated for tap/longPress).
  final List<dynamic> features;

  /// The layer IDs of the features found at the gesture location.
  final List<String> featureLayerIds;

  /// The timestamp of the gesture event.
  final DateTime timestamp;

  /// Creates a new [MapGestureEvent].
  const MapGestureEvent({
    required this.type,
    required this.latLng,
    required this.screenPoint,
    this.features = const [],
    this.featureLayerIds = const [],
    required this.timestamp,
  });

  /// Whether any features were found at the gesture location.
  bool get hasFeatures => features.isNotEmpty;
}

/// Callback signature for feature selection events.
typedef FeatureSelectionCallback = void Function(
  List<dynamic> features,
  LatLng latLng,
);

/// Callback signature for contextual action events on map gestures.
typedef ContextualActionCallback = void Function(
  MapGestureEvent event,
);

/// Handles map gesture events and provides a unified API for responding
/// to user interactions on the map.
///
/// Supports tap-to-select features, long press for context menus, and
/// custom gesture callbacks. Features are queried from specified layers
/// when a tap or long press occurs.
///
/// Usage:
/// ```dart
/// final gestureHandler = MapGestureHandler(
///   controller: mapController,
///   selectableLayerIds: ['field_boundary_layer', 'sensor_layer'],
///   onFeatureSelected: (features, latLng) {
///     // Handle feature selection.
///   },
///   onMapTap: (event) {
///     // Handle map tap without feature.
///   },
/// );
/// ```
class MapGestureHandler {
  final MapControllerWrapper _controller;

  /// Layer IDs that should be queried for feature selection on tap.
  final List<String> selectableLayerIds;

  /// Callback invoked when one or more features are selected via tap.
  final FeatureSelectionCallback? onFeatureSelected;

  /// Callback invoked when a tap occurs but no features are found.
  final ContextualActionCallback? onMapTap;

  /// Callback invoked on long press.
  final ContextualActionCallback? onMapLongPress;

  /// Callback invoked on any gesture event.
  final ContextualActionCallback? onGesture;

  final StreamController<MapGestureEvent> _gestureController =
      StreamController<MapGestureEvent>.broadcast();

  /// Tolerance in screen pixels for feature queries around the tap point.
  final double queryTolerance;

  /// Creates a new [MapGestureHandler].
  MapGestureHandler({
    required MapControllerWrapper controller,
    this.selectableLayerIds = const [],
    this.onFeatureSelected,
    this.onMapTap,
    this.onMapLongPress,
    this.onGesture,
    this.queryTolerance = 10.0,
  }) : _controller = controller;

  /// A stream of all gesture events.
  Stream<MapGestureEvent> get gestures => _gestureController.stream;

  /// A filtered stream of tap gesture events only.
  Stream<MapGestureEvent> get taps => _gestureController.stream
      .where((e) => e.type == MapGestureType.tap);

  /// A filtered stream of long press gesture events only.
  Stream<MapGestureEvent> get longPresses => _gestureController.stream
      .where((e) => e.type == MapGestureType.longPress);

  /// Handles a map tap event. Call this from the map widget's onMapClick.
  ///
  /// Queries features at the tap location from [selectableLayerIds] and
  /// invokes the appropriate callbacks.
  Future<void> handleTap(Point<num> screenPoint, LatLng latLng) async {
    List<dynamic> features = [];

    if (selectableLayerIds.isNotEmpty && _controller.isReady) {
      try {
        features = await _controller.queryRenderedFeatures(
          screenPoint,
          layerIds: selectableLayerIds,
        );
      } catch (_) {
        // Query may fail if layers don't exist yet.
      }
    }

    final event = MapGestureEvent(
      type: MapGestureType.tap,
      latLng: latLng,
      screenPoint: screenPoint,
      features: features,
      featureLayerIds: selectableLayerIds,
      timestamp: DateTime.now(),
    );

    _emitEvent(event);

    if (features.isNotEmpty) {
      onFeatureSelected?.call(features, latLng);
    } else {
      onMapTap?.call(event);
    }

    onGesture?.call(event);
  }

  /// Handles a map long press event. Call this from the map widget's
  /// onMapLongClick.
  Future<void> handleLongPress(Point<num> screenPoint, LatLng latLng) async {
    List<dynamic> features = [];

    if (selectableLayerIds.isNotEmpty && _controller.isReady) {
      try {
        features = await _controller.queryRenderedFeatures(
          screenPoint,
          layerIds: selectableLayerIds,
        );
      } catch (_) {
        // Query may fail if layers don't exist yet.
      }
    }

    final event = MapGestureEvent(
      type: MapGestureType.longPress,
      latLng: latLng,
      screenPoint: screenPoint,
      features: features,
      featureLayerIds: selectableLayerIds,
      timestamp: DateTime.now(),
    );

    _emitEvent(event);
    onMapLongPress?.call(event);
    onGesture?.call(event);
  }

  /// Creates the onMapClick callback for use with the map widget.
  void Function(Point<num>, LatLng) get onMapClickHandler => handleTap;

  /// Creates the onMapLongClick callback for use with the map widget.
  void Function(Point<num>, LatLng) get onMapLongClickHandler => handleLongPress;

  /// Queries features at a specific screen point from the given layer IDs.
  ///
  /// Returns a list of GeoJSON feature maps.
  Future<List<dynamic>> queryFeaturesAtPoint(
    Point<num> screenPoint, {
    List<String>? layerIds,
  }) async {
    if (!_controller.isReady) return [];

    return await _controller.queryRenderedFeatures(
      screenPoint,
      layerIds: layerIds ?? selectableLayerIds,
    );
  }

  /// Queries features within a bounding rectangle on screen.
  Future<List<dynamic>> queryFeaturesInRect(
    Rect rect, {
    List<String>? layerIds,
  }) async {
    if (!_controller.isReady) return [];

    return await _controller.queryRenderedFeaturesInRect(
      rect,
      layerIds: layerIds ?? selectableLayerIds,
    );
  }

  /// Disposes of resources.
  void dispose() {
    _gestureController.close();
  }

  void _emitEvent(MapGestureEvent event) {
    if (!_gestureController.isClosed) {
      _gestureController.add(event);
    }
  }
}
