import 'package:maplibre_gl/maplibre_gl.dart';

/// Configuration for initializing the map engine.
///
/// Encapsulates all settings needed to configure a MapLibre map instance
/// including style, camera position, zoom constraints, and optional bounds.
class MapConfig {
  /// The URL of the MapLibre style JSON to use for rendering.
  final String styleUrl;

  /// The initial center coordinate of the map.
  final LatLng initialCenter;

  /// The initial zoom level of the map.
  final double initialZoom;

  /// The minimum allowed zoom level.
  final double minZoom;

  /// The maximum allowed zoom level.
  final double maxZoom;

  /// Optional bounding box to constrain the visible map area.
  final LatLngBounds? bounds;

  /// Whether to show the user's location on the map.
  final bool myLocationEnabled;

  /// Whether to show the compass control.
  final bool compassEnabled;

  /// Whether rotation gestures are enabled.
  final bool rotateGesturesEnabled;

  /// Whether tilt gestures are enabled.
  final bool tiltGesturesEnabled;

  /// Whether zoom gestures are enabled.
  final bool zoomGesturesEnabled;

  /// Whether scroll/pan gestures are enabled.
  final bool scrollGesturesEnabled;

  /// Creates a new [MapConfig] with the given parameters.
  const MapConfig({
    required this.styleUrl,
    this.initialCenter = const LatLng(0.0, 0.0),
    this.initialZoom = 14.0,
    this.minZoom = 0.0,
    this.maxZoom = 22.0,
    this.bounds,
    this.myLocationEnabled = false,
    this.compassEnabled = true,
    this.rotateGesturesEnabled = true,
    this.tiltGesturesEnabled = true,
    this.zoomGesturesEnabled = true,
    this.scrollGesturesEnabled = true,
  });

  /// Creates a copy of this config with the given fields replaced.
  MapConfig copyWith({
    String? styleUrl,
    LatLng? initialCenter,
    double? initialZoom,
    double? minZoom,
    double? maxZoom,
    LatLngBounds? bounds,
    bool? myLocationEnabled,
    bool? compassEnabled,
    bool? rotateGesturesEnabled,
    bool? tiltGesturesEnabled,
    bool? zoomGesturesEnabled,
    bool? scrollGesturesEnabled,
  }) {
    return MapConfig(
      styleUrl: styleUrl ?? this.styleUrl,
      initialCenter: initialCenter ?? this.initialCenter,
      initialZoom: initialZoom ?? this.initialZoom,
      minZoom: minZoom ?? this.minZoom,
      maxZoom: maxZoom ?? this.maxZoom,
      bounds: bounds ?? this.bounds,
      myLocationEnabled: myLocationEnabled ?? this.myLocationEnabled,
      compassEnabled: compassEnabled ?? this.compassEnabled,
      rotateGesturesEnabled:
          rotateGesturesEnabled ?? this.rotateGesturesEnabled,
      tiltGesturesEnabled: tiltGesturesEnabled ?? this.tiltGesturesEnabled,
      zoomGesturesEnabled: zoomGesturesEnabled ?? this.zoomGesturesEnabled,
      scrollGesturesEnabled:
          scrollGesturesEnabled ?? this.scrollGesturesEnabled,
    );
  }

  /// Returns a default configuration suitable for agricultural use cases.
  ///
  /// Uses the MapLibre demo style and centers on a neutral location with
  /// agricultural-friendly zoom levels.
  factory MapConfig.agriculture({
    required String styleUrl,
    required LatLng farmCenter,
  }) {
    return MapConfig(
      styleUrl: styleUrl,
      initialCenter: farmCenter,
      initialZoom: 15.0,
      minZoom: 4.0,
      maxZoom: 22.0,
      myLocationEnabled: true,
      compassEnabled: true,
    );
  }
}

/// Represents a camera position on the map.
///
/// Defines the viewpoint including geographic target, zoom level,
/// bearing (rotation), and tilt (pitch).
class MapCameraPosition {
  /// The geographic coordinate the camera is pointed at.
  final LatLng target;

  /// The zoom level of the camera.
  final double zoom;

  /// The bearing (rotation) of the camera in degrees clockwise from north.
  final double bearing;

  /// The tilt (pitch) of the camera in degrees from the nadir.
  final double tilt;

  /// Creates a new [MapCameraPosition].
  const MapCameraPosition({
    required this.target,
    this.zoom = 14.0,
    this.bearing = 0.0,
    this.tilt = 0.0,
  });

  /// Converts this position to a MapLibre [CameraUpdate] for camera moves.
  CameraUpdate toCameraUpdate() {
    return CameraUpdate.newLatLngZoom(target, zoom);
  }

  /// Creates a copy of this position with the given fields replaced.
  MapCameraPosition copyWith({
    LatLng? target,
    double? zoom,
    double? bearing,
    double? tilt,
  }) {
    return MapCameraPosition(
      target: target ?? this.target,
      zoom: zoom ?? this.zoom,
      bearing: bearing ?? this.bearing,
      tilt: tilt ?? this.tilt,
    );
  }

  @override
  String toString() =>
      'MapCameraPosition(target: $target, zoom: $zoom, bearing: $bearing, tilt: $tilt)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MapCameraPosition &&
        other.target == target &&
        other.zoom == zoom &&
        other.bearing == bearing &&
        other.tilt == tilt;
  }

  @override
  int get hashCode => Object.hash(target, zoom, bearing, tilt);
}
