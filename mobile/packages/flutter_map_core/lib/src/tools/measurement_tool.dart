import 'dart:async';

import 'package:maplibre_gl/maplibre_gl.dart';

import '../engine/geo_utils.dart';
import '../engine/map_controller_wrapper.dart';
import '../layers/geojson_source.dart';

/// The type of measurement being performed.
enum MeasurementMode {
  /// Measuring distances along a polyline.
  distance,

  /// Measuring the area of a polygon.
  area,
}

/// Result of a measurement operation.
class MeasurementResult {
  /// The mode of measurement.
  final MeasurementMode mode;

  /// The points that define the measurement geometry.
  final List<LatLng> points;

  /// The total distance in meters (for distance mode) or perimeter
  /// in meters (for area mode).
  final double distanceMeters;

  /// The area in square meters (for area mode), or 0 for distance mode.
  final double areaSquareMeters;

  /// The area in hectares (for area mode), or 0 for distance mode.
  double get areaHectares => areaSquareMeters / 10000.0;

  /// The distance in kilometers.
  double get distanceKilometers => distanceMeters / 1000.0;

  /// Human-readable distance string.
  String get formattedDistance => GeoUtils.formatDistance(distanceMeters);

  /// Human-readable area string.
  String get formattedArea => GeoUtils.formatArea(areaSquareMeters);

  const MeasurementResult({
    required this.mode,
    required this.points,
    required this.distanceMeters,
    required this.areaSquareMeters,
  });
}

/// A tool for measuring distances and areas on the map.
///
/// In distance mode, users tap points to create a polyline, and the tool
/// calculates the total distance. In area mode, users tap points to create
/// a polygon, and the tool calculates the enclosed area.
///
/// Visual feedback includes point markers, connecting lines, and
/// measurement labels.
class MeasurementTool {
  final MapControllerWrapper _controller;

  static const String _pointSourceId = 'measurement_points';
  static const String _lineSourceId = 'measurement_lines';
  static const String _fillSourceId = 'measurement_fill';
  static const String _labelSourceId = 'measurement_labels';

  static const String _pointLayerId = 'measurement_point_layer';
  static const String _lineLayerId = 'measurement_line_layer';
  static const String _fillLayerId = 'measurement_fill_layer';
  static const String _labelLayerId = 'measurement_label_layer';

  final List<LatLng> _points = [];

  late final GeoJsonSource _pointSource;
  late final GeoJsonSource _lineSource;
  late final GeoJsonSource _fillSource;
  late final GeoJsonSource _labelSource;

  MeasurementMode _mode;
  bool _isActivated = false;

  final StreamController<MeasurementResult> _resultController =
      StreamController<MeasurementResult>.broadcast();

  /// Creates a new [MeasurementTool] with the given [mode].
  MeasurementTool({
    required MapControllerWrapper controller,
    MeasurementMode mode = MeasurementMode.distance,
  })  : _controller = controller,
        _mode = mode {
    _pointSource = GeoJsonSource(sourceId: _pointSourceId);
    _lineSource = GeoJsonSource(sourceId: _lineSourceId);
    _fillSource = GeoJsonSource(sourceId: _fillSourceId);
    _labelSource = GeoJsonSource(sourceId: _labelSourceId);
  }

  /// The current measurement mode.
  MeasurementMode get mode => _mode;

  /// The current measurement points.
  List<LatLng> get points => List.unmodifiable(_points);

  /// A stream of measurement results, updated each time a point is
  /// added or removed.
  Stream<MeasurementResult> get results => _resultController.stream;

  /// Whether the tool is currently active.
  bool get isActive => _isActivated;

  /// Sets the measurement mode.
  ///
  /// Resets the current measurement if the mode changes.
  Future<void> setMode(MeasurementMode newMode) async {
    if (_mode == newMode) return;
    _mode = newMode;
    await reset();
  }

  /// Activates the measurement tool.
  Future<void> activate() async {
    if (_isActivated) return;

    await _fillSource.addToMap(_controller);
    await _lineSource.addToMap(_controller);
    await _pointSource.addToMap(_controller);
    await _labelSource.addToMap(_controller);

    // Fill layer (for area mode).
    await _controller.addFillLayer(
      _fillSourceId,
      _fillLayerId,
      properties: {
        'fill-color': '#FF9800',
        'fill-opacity': 0.15,
      },
    );

    // Line layer.
    await _controller.addLineLayer(
      _lineSourceId,
      _lineLayerId,
      properties: {
        'line-color': '#FF9800',
        'line-width': 2.5,
        'line-dasharray': [3.0, 2.0],
      },
    );

    // Point layer.
    await _controller.addCircleLayer(
      _pointSourceId,
      _pointLayerId,
      properties: {
        'circle-radius': 5.0,
        'circle-color': '#FFFFFF',
        'circle-stroke-color': '#FF9800',
        'circle-stroke-width': 2.0,
      },
    );

    // Label layer.
    await _controller.addSymbolLayer(
      _labelSourceId,
      _labelLayerId,
      properties: {
        'text-field': ['get', 'label'],
        'text-size': 12.0,
        'text-color': '#333333',
        'text-halo-color': '#FFFFFF',
        'text-halo-width': 1.5,
      },
    );

    _isActivated = true;
  }

  /// Adds a measurement point.
  Future<void> addPoint(LatLng point) async {
    _points.add(point);
    await _updateVisuals();
    _emitResult();
  }

  /// Removes the last measurement point.
  Future<void> undoLastPoint() async {
    if (_points.isEmpty) return;
    _points.removeLast();
    await _updateVisuals();
    _emitResult();
  }

  /// Resets the measurement, clearing all points.
  Future<void> reset() async {
    _points.clear();
    await _updateVisuals();
  }

  /// Calculates the current measurement result.
  MeasurementResult calculateResult() {
    double distance = 0;
    double area = 0;

    if (_points.length >= 2) {
      distance = GeoUtils.polylineDistance(_points);
    }

    if (_mode == MeasurementMode.area && _points.length >= 3) {
      area = GeoUtils.polygonArea(_points);
      // Add closing segment distance.
      distance += GeoUtils.haversineDistance(_points.last, _points.first);
    }

    return MeasurementResult(
      mode: _mode,
      points: List.unmodifiable(_points),
      distanceMeters: distance,
      areaSquareMeters: area,
    );
  }

  /// Calculates the distance between two specific points.
  static double distanceBetween(LatLng from, LatLng to) {
    return GeoUtils.haversineDistance(from, to);
  }

  /// Calculates the area of a polygon defined by vertices.
  static double areaOfPolygon(List<LatLng> vertices) {
    return GeoUtils.polygonArea(vertices);
  }

  /// Calculates the area of a polygon in hectares.
  static double areaOfPolygonHectares(List<LatLng> vertices) {
    return GeoUtils.polygonAreaHectares(vertices);
  }

  /// Deactivates the measurement tool.
  Future<void> deactivate() async {
    if (!_isActivated) return;

    try {
      await _controller.removeLayer(_labelLayerId);
      await _controller.removeLayer(_pointLayerId);
      await _controller.removeLayer(_lineLayerId);
      await _controller.removeLayer(_fillLayerId);
      await _labelSource.removeFromMap(_controller);
      await _pointSource.removeFromMap(_controller);
      await _lineSource.removeFromMap(_controller);
      await _fillSource.removeFromMap(_controller);
    } catch (_) {
      // Layers may already have been removed.
    }

    _points.clear();
    _isActivated = false;
  }

  /// Disposes of resources.
  void dispose() {
    _resultController.close();
  }

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  Future<void> _updateVisuals() async {
    if (!_isActivated) return;

    // Points.
    final pointFeatures = _points
        .asMap()
        .entries
        .map((e) => GeoJsonSource.pointFeature(
              e.value,
              id: 'measure_point_${e.key}',
            ))
        .toList();
    await _pointSource.setFeatures(_controller, pointFeatures);

    // Line.
    if (_points.length >= 2) {
      final linePoints = List<LatLng>.from(_points);
      if (_mode == MeasurementMode.area && _points.length >= 3) {
        linePoints.add(_points.first);
      }
      await _lineSource.setFeatures(_controller, [
        GeoJsonSource.lineFeature(linePoints, id: 'measure_line'),
      ]);
    } else {
      await _lineSource.clear(_controller);
    }

    // Fill (area mode only).
    if (_mode == MeasurementMode.area && _points.length >= 3) {
      await _fillSource.setFeatures(_controller, [
        GeoJsonSource.polygonFeature(_points, id: 'measure_fill'),
      ]);
    } else {
      await _fillSource.clear(_controller);
    }

    // Labels: segment distances and total.
    await _updateLabels();
  }

  Future<void> _updateLabels() async {
    final labels = <Map<String, dynamic>>[];

    // Segment distance labels.
    for (int i = 0; i < _points.length - 1; i++) {
      final midpoint = GeoUtils.midpoint(_points[i], _points[i + 1]);
      final segmentDist = GeoUtils.haversineDistance(_points[i], _points[i + 1]);
      labels.add(GeoJsonSource.pointFeature(
        midpoint,
        id: 'segment_label_$i',
        properties: {
          'label': GeoUtils.formatDistance(segmentDist),
        },
      ));
    }

    // Total / area label at centroid.
    if (_points.length >= 2) {
      final result = calculateResult();
      final labelPoint = _mode == MeasurementMode.area && _points.length >= 3
          ? GeoUtils.polygonCentroid(_points)
          : _points.last;

      String totalLabel;
      if (_mode == MeasurementMode.area && _points.length >= 3) {
        totalLabel =
            '${result.formattedArea}\n${GeoUtils.formatDistance(result.distanceMeters)}';
      } else {
        totalLabel = result.formattedDistance;
      }

      labels.add(GeoJsonSource.pointFeature(
        labelPoint,
        id: 'total_label',
        properties: {'label': totalLabel},
      ));
    }

    await _labelSource.setFeatures(_controller, labels);
  }

  void _emitResult() {
    if (!_resultController.isClosed) {
      _resultController.add(calculateResult());
    }
  }
}
