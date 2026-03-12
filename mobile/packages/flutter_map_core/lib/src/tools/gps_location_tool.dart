import 'dart:async';
import 'dart:math';

import 'package:geolocator/geolocator.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../engine/geo_utils.dart';
import '../engine/map_controller_wrapper.dart';
import '../layers/geojson_source.dart';

/// GPS tracking state.
enum GpsTrackingState {
  /// GPS tracking is disabled.
  disabled,

  /// Acquiring initial position fix.
  acquiring,

  /// Actively tracking the user's position.
  tracking,

  /// Tracking with heading (compass) indicator.
  trackingWithHeading,

  /// An error occurred (permissions, services, etc.).
  error,
}

/// Represents a GPS position with accuracy and heading information.
class GpsPosition {
  /// The geographic coordinates.
  final LatLng latLng;

  /// The horizontal accuracy in meters.
  final double accuracyMeters;

  /// The heading in degrees (0-360, clockwise from north).
  /// May be `null` if heading is unavailable.
  final double? heading;

  /// The altitude in meters above sea level.
  /// May be `null` if unavailable.
  final double? altitude;

  /// The speed in meters per second.
  final double speed;

  /// The timestamp of the position fix.
  final DateTime timestamp;

  const GpsPosition({
    required this.latLng,
    required this.accuracyMeters,
    this.heading,
    this.altitude,
    this.speed = 0.0,
    required this.timestamp,
  });

  /// Creates a [GpsPosition] from a Geolocator [Position].
  factory GpsPosition.fromPosition(Position position) {
    return GpsPosition(
      latLng: LatLng(position.latitude, position.longitude),
      accuracyMeters: position.accuracy,
      heading: position.heading > 0 ? position.heading : null,
      altitude: position.altitude,
      speed: position.speed,
      timestamp: position.timestamp,
    );
  }
}

/// A tool for GPS-based location tracking on the map.
///
/// Provides the user's current position, continuous tracking with heading
/// indicator, and an accuracy circle visualization.
///
/// Usage:
/// ```dart
/// final gpsTool = GpsLocationTool(controller: mapController);
/// await gpsTool.activate();
///
/// // Listen for position updates:
/// gpsTool.positionStream.listen((position) {
///   print('Lat: ${position.latLng.latitude}, Lng: ${position.latLng.longitude}');
/// });
///
/// // Center map on current location:
/// await gpsTool.centerOnLocation();
/// ```
class GpsLocationTool {
  final MapControllerWrapper _controller;

  static const String _positionSourceId = 'gps_position';
  static const String _accuracySourceId = 'gps_accuracy';
  static const String _headingSourceId = 'gps_heading';

  static const String _positionLayerId = 'gps_position_layer';
  static const String _accuracyLayerId = 'gps_accuracy_layer';
  static const String _headingLayerId = 'gps_heading_layer';

  late final GeoJsonSource _positionSource;
  late final GeoJsonSource _accuracySource;
  late final GeoJsonSource _headingSource;

  GpsTrackingState _state = GpsTrackingState.disabled;
  GpsPosition? _currentPosition;
  StreamSubscription<Position>? _positionSubscription;
  bool _isActivated = false;

  /// Whether to automatically center the map on position updates.
  bool followUser;

  /// Whether to show the accuracy circle.
  bool showAccuracyCircle;

  /// Whether to show the heading indicator.
  bool showHeading;

  /// Location settings for the Geolocator stream.
  final LocationSettings _locationSettings;

  final StreamController<GpsPosition> _positionController =
      StreamController<GpsPosition>.broadcast();
  final StreamController<GpsTrackingState> _stateController =
      StreamController<GpsTrackingState>.broadcast();

  /// Creates a new [GpsLocationTool].
  GpsLocationTool({
    required MapControllerWrapper controller,
    this.followUser = true,
    this.showAccuracyCircle = true,
    this.showHeading = true,
    LocationSettings? locationSettings,
  })  : _controller = controller,
        _locationSettings = locationSettings ??
            const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 5,
            ) {
    _positionSource = GeoJsonSource(sourceId: _positionSourceId);
    _accuracySource = GeoJsonSource(sourceId: _accuracySourceId);
    _headingSource = GeoJsonSource(sourceId: _headingSourceId);
  }

  /// The current tracking state.
  GpsTrackingState get state => _state;

  /// A stream of tracking state changes.
  Stream<GpsTrackingState> get stateChanges => _stateController.stream;

  /// The most recent GPS position, or `null` if unavailable.
  GpsPosition? get currentPosition => _currentPosition;

  /// A stream of GPS position updates.
  Stream<GpsPosition> get positionStream => _positionController.stream;

  /// Whether GPS tracking is currently active.
  bool get isTracking =>
      _state == GpsTrackingState.tracking ||
      _state == GpsTrackingState.trackingWithHeading;

  /// Checks and requests location permissions.
  ///
  /// Returns `true` if location services are enabled and permissions are
  /// granted.
  Future<bool> checkPermissions() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }

    if (permission == LocationPermission.deniedForever) return false;

    return true;
  }

  /// Activates the GPS tool and adds visualization layers to the map.
  Future<void> activate() async {
    if (_isActivated) return;

    final hasPermission = await checkPermissions();
    if (!hasPermission) {
      _setState(GpsTrackingState.error);
      return;
    }

    // Add sources.
    await _accuracySource.addToMap(_controller);
    await _headingSource.addToMap(_controller);
    await _positionSource.addToMap(_controller);

    // Accuracy circle (fill).
    await _controller.addFillLayer(
      _accuracySourceId,
      _accuracyLayerId,
      properties: {
        'fill-color': '#2196F3',
        'fill-opacity': 0.1,
      },
    );

    // Heading indicator (line from position in heading direction).
    await _controller.addLineLayer(
      _headingSourceId,
      _headingLayerId,
      properties: {
        'line-color': '#2196F3',
        'line-width': 2.0,
        'line-opacity': 0.7,
      },
    );

    // Position dot.
    await _controller.addCircleLayer(
      _positionSourceId,
      _positionLayerId,
      properties: {
        'circle-radius': 8.0,
        'circle-color': '#2196F3',
        'circle-stroke-color': '#FFFFFF',
        'circle-stroke-width': 3.0,
      },
    );

    _isActivated = true;
    _setState(GpsTrackingState.acquiring);

    // Get initial position.
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: _locationSettings,
      );
      await _onPositionUpdate(position);
    } catch (e) {
      _setState(GpsTrackingState.error);
      return;
    }

    // Start continuous tracking.
    await _startTracking();
  }

  /// Gets the current position as a one-shot request.
  Future<GpsPosition?> getCurrentPosition() async {
    try {
      final hasPermission = await checkPermissions();
      if (!hasPermission) return null;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: _locationSettings,
      );
      return GpsPosition.fromPosition(position);
    } catch (_) {
      return null;
    }
  }

  /// Centers the map on the current GPS position.
  Future<void> centerOnLocation({double? zoom}) async {
    final pos = _currentPosition;
    if (pos == null) return;

    if (zoom != null) {
      await _controller.animateCamera(
        CameraUpdate.newLatLngZoom(pos.latLng, zoom),
      );
    } else {
      await _controller.animateCamera(
        CameraUpdate.newLatLng(pos.latLng),
      );
    }
  }

  /// Toggles between tracking modes: disabled -> tracking -> trackingWithHeading -> disabled.
  Future<void> cycleTrackingMode() async {
    switch (_state) {
      case GpsTrackingState.disabled:
      case GpsTrackingState.error:
        await activate();
        break;
      case GpsTrackingState.acquiring:
      case GpsTrackingState.tracking:
        _setState(GpsTrackingState.trackingWithHeading);
        followUser = true;
        showHeading = true;
        break;
      case GpsTrackingState.trackingWithHeading:
        await deactivate();
        break;
    }
  }

  /// Deactivates GPS tracking and removes visualization layers.
  Future<void> deactivate() async {
    await _stopTracking();

    if (_isActivated) {
      try {
        await _controller.removeLayer(_positionLayerId);
        await _controller.removeLayer(_headingLayerId);
        await _controller.removeLayer(_accuracyLayerId);
        await _positionSource.removeFromMap(_controller);
        await _headingSource.removeFromMap(_controller);
        await _accuracySource.removeFromMap(_controller);
      } catch (_) {
        // Layers may already have been removed.
      }
    }

    _currentPosition = null;
    _isActivated = false;
    _setState(GpsTrackingState.disabled);
  }

  /// Disposes of resources.
  void dispose() {
    _positionSubscription?.cancel();
    _positionController.close();
    _stateController.close();
  }

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  Future<void> _startTracking() async {
    await _stopTracking();

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: _locationSettings,
    ).listen(
      _onPositionUpdate,
      onError: (error) {
        _setState(GpsTrackingState.error);
      },
    );
  }

  Future<void> _stopTracking() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  Future<void> _onPositionUpdate(Position position) async {
    final gpsPos = GpsPosition.fromPosition(position);
    _currentPosition = gpsPos;

    if (_state == GpsTrackingState.acquiring) {
      _setState(GpsTrackingState.tracking);
    }

    if (!_positionController.isClosed) {
      _positionController.add(gpsPos);
    }

    await _updateVisuals(gpsPos);

    if (followUser) {
      await _controller.animateCamera(
        CameraUpdate.newLatLng(gpsPos.latLng),
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  Future<void> _updateVisuals(GpsPosition position) async {
    if (!_isActivated) return;

    // Update position dot.
    await _positionSource.setFeatures(_controller, [
      GeoJsonSource.pointFeature(
        position.latLng,
        id: 'gps_position',
        properties: {
          'accuracy': position.accuracyMeters,
          'heading': position.heading ?? 0,
        },
      ),
    ]);

    // Update accuracy circle.
    if (showAccuracyCircle && position.accuracyMeters > 0) {
      final circlePoints = _generateCirclePolygon(
        position.latLng,
        position.accuracyMeters,
        segments: 64,
      );
      await _accuracySource.setFeatures(_controller, [
        GeoJsonSource.polygonFeature(circlePoints, id: 'gps_accuracy'),
      ]);
    } else {
      await _accuracySource.clear(_controller);
    }

    // Update heading indicator.
    if (showHeading && position.heading != null) {
      final headingEnd = GeoUtils.destinationPoint(
        position.latLng,
        position.heading!,
        max(position.accuracyMeters * 2, 30.0),
      );
      await _headingSource.setFeatures(_controller, [
        GeoJsonSource.lineFeature(
          [position.latLng, headingEnd],
          id: 'gps_heading',
        ),
      ]);
    } else {
      await _headingSource.clear(_controller);
    }
  }

  /// Generates a polygon approximating a circle.
  List<LatLng> _generateCirclePolygon(
    LatLng center,
    double radiusMeters, {
    int segments = 64,
  }) {
    final points = <LatLng>[];
    for (int i = 0; i <= segments; i++) {
      final bearing = (360.0 / segments) * i;
      points.add(GeoUtils.destinationPoint(center, bearing, radiusMeters));
    }
    return points;
  }

  void _setState(GpsTrackingState newState) {
    if (_state == newState) return;
    _state = newState;
    if (!_stateController.isClosed) {
      _stateController.add(_state);
    }
  }
}
