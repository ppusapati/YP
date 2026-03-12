import 'dart:async';

import 'package:maplibre_gl/maplibre_gl.dart';

import '../engine/geo_utils.dart';
import '../engine/map_controller_wrapper.dart';
import '../layers/geojson_source.dart';

/// State of the polygon drawing tool.
enum PolygonDrawState {
  /// The tool is idle and not drawing.
  idle,

  /// The user is actively placing vertices.
  drawing,

  /// The polygon has been closed and is complete.
  completed,
}

/// A tool for interactively drawing polygons on the map.
///
/// Users tap on the map to add vertices. The tool provides visual feedback
/// with markers at each vertex and lines connecting them. The polygon can
/// be closed to complete the drawing.
///
/// Usage:
/// ```dart
/// final drawTool = PolygonDrawTool(controller: mapController);
/// await drawTool.activate();
///
/// // When the user taps the map:
/// await drawTool.addVertex(tappedLatLng);
///
/// // To undo the last vertex:
/// await drawTool.undoLastVertex();
///
/// // To complete the polygon:
/// await drawTool.closePolygon();
///
/// // Get the result:
/// final coordinates = drawTool.vertices;
/// final areaHa = drawTool.areaHectares;
/// ```
class PolygonDrawTool {
  final MapControllerWrapper _controller;

  /// Source IDs used by the draw tool.
  static const String _vertexSourceId = 'polygon_draw_vertices';
  static const String _lineSourceId = 'polygon_draw_lines';
  static const String _fillSourceId = 'polygon_draw_fill';

  /// Layer IDs used by the draw tool.
  static const String _vertexLayerId = 'polygon_draw_vertex_layer';
  static const String _lineLayerId = 'polygon_draw_line_layer';
  static const String _fillLayerId = 'polygon_draw_fill_layer';

  final List<LatLng> _vertices = [];

  late final GeoJsonSource _vertexSource;
  late final GeoJsonSource _lineSource;
  late final GeoJsonSource _fillSource;

  PolygonDrawState _state = PolygonDrawState.idle;
  bool _isActivated = false;

  final StreamController<PolygonDrawState> _stateController =
      StreamController<PolygonDrawState>.broadcast();

  /// Creates a new [PolygonDrawTool] bound to the given [controller].
  PolygonDrawTool({required MapControllerWrapper controller})
      : _controller = controller {
    _vertexSource = GeoJsonSource(sourceId: _vertexSourceId);
    _lineSource = GeoJsonSource(sourceId: _lineSourceId);
    _fillSource = GeoJsonSource(sourceId: _fillSourceId);
  }

  /// The current state of the drawing tool.
  PolygonDrawState get state => _state;

  /// A stream of state changes.
  Stream<PolygonDrawState> get stateChanges => _stateController.stream;

  /// The current list of vertices in the polygon being drawn.
  List<LatLng> get vertices => List.unmodifiable(_vertices);

  /// The number of vertices placed so far.
  int get vertexCount => _vertices.length;

  /// Whether the polygon has enough vertices to be closed (>= 3).
  bool get canClose => _vertices.length >= 3;

  /// Whether the tool is currently active and drawing.
  bool get isActive => _isActivated && _state == PolygonDrawState.drawing;

  /// The area of the current polygon in hectares.
  ///
  /// Returns 0 if fewer than 3 vertices have been placed.
  double get areaHectares {
    if (_vertices.length < 3) return 0.0;
    return GeoUtils.polygonAreaHectares(_vertices);
  }

  /// The perimeter of the current polygon in meters.
  double get perimeterMeters {
    if (_vertices.length < 2) return 0.0;
    final points = List<LatLng>.from(_vertices);
    if (_vertices.length >= 3) {
      points.add(_vertices.first); // close the ring
    }
    return GeoUtils.polylineDistance(points);
  }

  /// Activates the drawing tool by adding necessary sources and layers
  /// to the map.
  Future<void> activate() async {
    if (_isActivated) return;

    // Add sources.
    await _fillSource.addToMap(_controller);
    await _lineSource.addToMap(_controller);
    await _vertexSource.addToMap(_controller);

    // Add fill layer (semi-transparent).
    await _controller.addFillLayer(
      _fillSourceId,
      _fillLayerId,
      properties: {
        'fill-color': '#4CAF50',
        'fill-opacity': 0.15,
      },
    );

    // Add line layer.
    await _controller.addLineLayer(
      _lineSourceId,
      _lineLayerId,
      properties: {
        'line-color': '#4CAF50',
        'line-width': 2.5,
        'line-dasharray': [2.0, 1.0],
      },
    );

    // Add vertex circle layer.
    await _controller.addCircleLayer(
      _vertexSourceId,
      _vertexLayerId,
      properties: {
        'circle-radius': 6.0,
        'circle-color': '#FFFFFF',
        'circle-stroke-color': '#4CAF50',
        'circle-stroke-width': 2.5,
      },
    );

    _isActivated = true;
    _setState(PolygonDrawState.drawing);
  }

  /// Adds a vertex at the given [point] coordinates.
  ///
  /// Does nothing if the tool is not in the [PolygonDrawState.drawing] state.
  Future<void> addVertex(LatLng point) async {
    if (_state != PolygonDrawState.drawing) return;

    _vertices.add(point);
    await _updateVisuals();
  }

  /// Removes the last added vertex.
  ///
  /// If no vertices remain, the state returns to drawing (but empty).
  Future<void> undoLastVertex() async {
    if (_vertices.isEmpty) return;

    // If polygon was completed, reopen it.
    if (_state == PolygonDrawState.completed) {
      _setState(PolygonDrawState.drawing);
    }

    _vertices.removeLast();
    await _updateVisuals();
  }

  /// Closes the polygon by connecting the last vertex to the first.
  ///
  /// Requires at least 3 vertices. After closing, the state changes to
  /// [PolygonDrawState.completed].
  Future<void> closePolygon() async {
    if (!canClose) return;

    _setState(PolygonDrawState.completed);
    await _updateVisuals();
  }

  /// Returns the polygon coordinates as a closed ring suitable for GeoJSON.
  ///
  /// Returns `null` if the polygon is not complete.
  List<LatLng>? getClosedPolygon() {
    if (_vertices.length < 3) return null;

    final closed = List<LatLng>.from(_vertices);
    if (closed.first.latitude != closed.last.latitude ||
        closed.first.longitude != closed.last.longitude) {
      closed.add(closed.first);
    }
    return closed;
  }

  /// Returns the polygon as a GeoJSON Feature map.
  ///
  /// Returns `null` if the polygon is not complete.
  Map<String, dynamic>? toGeoJsonFeature({
    String? id,
    Map<String, dynamic>? properties,
  }) {
    if (_vertices.length < 3) return null;
    return GeoJsonSource.polygonFeature(
      _vertices,
      id: id,
      properties: properties,
    );
  }

  /// Resets the tool, clearing all vertices and returning to idle.
  Future<void> reset() async {
    _vertices.clear();
    _setState(PolygonDrawState.drawing);
    await _updateVisuals();
  }

  /// Deactivates the tool and removes all drawing layers and sources.
  Future<void> deactivate() async {
    if (!_isActivated) return;

    try {
      await _controller.removeLayer(_vertexLayerId);
      await _controller.removeLayer(_lineLayerId);
      await _controller.removeLayer(_fillLayerId);
      await _vertexSource.removeFromMap(_controller);
      await _lineSource.removeFromMap(_controller);
      await _fillSource.removeFromMap(_controller);
    } catch (_) {
      // Layers may already have been removed.
    }

    _vertices.clear();
    _isActivated = false;
    _setState(PolygonDrawState.idle);
  }

  /// Disposes of resources.
  void dispose() {
    _stateController.close();
  }

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  Future<void> _updateVisuals() async {
    if (!_isActivated) return;

    // Update vertex markers.
    final vertexFeatures = _vertices
        .asMap()
        .entries
        .map((e) => GeoJsonSource.pointFeature(
              e.value,
              id: 'vertex_${e.key}',
              properties: {'index': e.key},
            ))
        .toList();
    await _vertexSource.setFeatures(_controller, vertexFeatures);

    // Update line.
    if (_vertices.length >= 2) {
      final linePoints = List<LatLng>.from(_vertices);
      if (_state == PolygonDrawState.completed && _vertices.length >= 3) {
        linePoints.add(_vertices.first);
      }
      final lineFeature = GeoJsonSource.lineFeature(
        linePoints,
        id: 'draw_line',
      );
      await _lineSource.setFeatures(_controller, [lineFeature]);
    } else {
      await _lineSource.clear(_controller);
    }

    // Update fill.
    if (_vertices.length >= 3) {
      final fillFeature = GeoJsonSource.polygonFeature(
        _vertices,
        id: 'draw_fill',
      );
      await _fillSource.setFeatures(_controller, [fillFeature]);
    } else {
      await _fillSource.clear(_controller);
    }
  }

  void _setState(PolygonDrawState newState) {
    if (_state == newState) return;
    _state = newState;
    if (!_stateController.isClosed) {
      _stateController.add(_state);
    }
  }
}
