import 'dart:async';

import 'package:maplibre_gl/maplibre_gl.dart';

import '../engine/geo_utils.dart';
import '../engine/map_controller_wrapper.dart';
import '../layers/geojson_source.dart';

/// State of the polygon edit tool.
enum PolygonEditState {
  /// The tool is idle and not editing.
  idle,

  /// The tool is active and vertices can be manipulated.
  editing,

  /// A vertex is currently being dragged.
  dragging,
}

/// A tool for editing existing polygon geometries on the map.
///
/// Supports dragging vertices to new positions, adding midpoint vertices
/// between existing ones, and deleting vertices. Visual feedback includes
/// vertex handles and midpoint handles.
///
/// Usage:
/// ```dart
/// final editTool = PolygonEditTool(controller: mapController);
/// await editTool.startEditing(polygonVertices);
///
/// // Drag vertex at index 2 to new position:
/// await editTool.moveVertex(2, newLatLng);
///
/// // Insert a midpoint vertex between indices 1 and 2:
/// await editTool.addMidpointVertex(1);
///
/// // Delete vertex at index 3:
/// await editTool.deleteVertex(3);
///
/// // Get the updated polygon:
/// final updatedVertices = editTool.vertices;
/// ```
class PolygonEditTool {
  final MapControllerWrapper _controller;

  static const String _vertexSourceId = 'polygon_edit_vertices';
  static const String _midpointSourceId = 'polygon_edit_midpoints';
  static const String _lineSourceId = 'polygon_edit_lines';
  static const String _fillSourceId = 'polygon_edit_fill';

  static const String _vertexLayerId = 'polygon_edit_vertex_layer';
  static const String _midpointLayerId = 'polygon_edit_midpoint_layer';
  static const String _lineLayerId = 'polygon_edit_line_layer';
  static const String _fillLayerId = 'polygon_edit_fill_layer';

  final List<LatLng> _vertices = [];

  late final GeoJsonSource _vertexSource;
  late final GeoJsonSource _midpointSource;
  late final GeoJsonSource _lineSource;
  late final GeoJsonSource _fillSource;

  PolygonEditState _state = PolygonEditState.idle;
  int? _draggingVertexIndex;
  bool _isActivated = false;

  /// An optional callback for when the polygon source should be updated
  /// externally (e.g., updating a field boundary source).
  final Future<void> Function(List<LatLng> updatedVertices)? onPolygonUpdated;

  final StreamController<PolygonEditState> _stateController =
      StreamController<PolygonEditState>.broadcast();

  /// Creates a new [PolygonEditTool].
  PolygonEditTool({
    required MapControllerWrapper controller,
    this.onPolygonUpdated,
  }) : _controller = controller {
    _vertexSource = GeoJsonSource(sourceId: _vertexSourceId);
    _midpointSource = GeoJsonSource(sourceId: _midpointSourceId);
    _lineSource = GeoJsonSource(sourceId: _lineSourceId);
    _fillSource = GeoJsonSource(sourceId: _fillSourceId);
  }

  /// The current edit state.
  PolygonEditState get state => _state;

  /// A stream of edit state changes.
  Stream<PolygonEditState> get stateChanges => _stateController.stream;

  /// The current vertices of the polygon being edited.
  List<LatLng> get vertices => List.unmodifiable(_vertices);

  /// The number of vertices in the polygon.
  int get vertexCount => _vertices.length;

  /// Whether the tool is currently editing.
  bool get isEditing =>
      _state == PolygonEditState.editing || _state == PolygonEditState.dragging;

  /// The index of the vertex currently being dragged, or null.
  int? get draggingVertexIndex => _draggingVertexIndex;

  /// The area of the polygon in hectares.
  double get areaHectares {
    if (_vertices.length < 3) return 0.0;
    return GeoUtils.polygonAreaHectares(_vertices);
  }

  /// Starts editing the given polygon vertices.
  ///
  /// Adds edit handles (vertex and midpoint markers) and visual feedback
  /// layers to the map.
  Future<void> startEditing(List<LatLng> polygonVertices) async {
    if (_isActivated) {
      await stopEditing();
    }

    _vertices
      ..clear()
      ..addAll(polygonVertices);

    // Remove closing vertex if present (we handle closure internally).
    if (_vertices.length > 1 &&
        _vertices.first.latitude == _vertices.last.latitude &&
        _vertices.first.longitude == _vertices.last.longitude) {
      _vertices.removeLast();
    }

    // Add sources.
    await _fillSource.addToMap(_controller);
    await _lineSource.addToMap(_controller);
    await _midpointSource.addToMap(_controller);
    await _vertexSource.addToMap(_controller);

    // Add fill layer.
    await _controller.addFillLayer(
      _fillSourceId,
      _fillLayerId,
      properties: {
        'fill-color': '#2196F3',
        'fill-opacity': 0.12,
      },
    );

    // Add line layer.
    await _controller.addLineLayer(
      _lineSourceId,
      _lineLayerId,
      properties: {
        'line-color': '#2196F3',
        'line-width': 2.0,
      },
    );

    // Add midpoint circle layer.
    await _controller.addCircleLayer(
      _midpointSourceId,
      _midpointLayerId,
      properties: {
        'circle-radius': 4.0,
        'circle-color': '#90CAF9',
        'circle-stroke-color': '#2196F3',
        'circle-stroke-width': 1.5,
      },
    );

    // Add vertex circle layer.
    await _controller.addCircleLayer(
      _vertexSourceId,
      _vertexLayerId,
      properties: {
        'circle-radius': 7.0,
        'circle-color': '#FFFFFF',
        'circle-stroke-color': '#2196F3',
        'circle-stroke-width': 2.5,
      },
    );

    _isActivated = true;
    _setState(PolygonEditState.editing);
    await _updateVisuals();
  }

  /// Moves the vertex at [index] to a new [position].
  ///
  /// Updates all visual layers accordingly.
  Future<void> moveVertex(int index, LatLng position) async {
    if (index < 0 || index >= _vertices.length) return;

    _vertices[index] = position;
    await _updateVisuals();
    await _notifyPolygonUpdated();
  }

  /// Begins dragging the vertex at [index].
  void startDragVertex(int index) {
    if (index < 0 || index >= _vertices.length) return;
    _draggingVertexIndex = index;
    _setState(PolygonEditState.dragging);
  }

  /// Updates the position of the currently dragged vertex.
  Future<void> updateDragPosition(LatLng position) async {
    if (_draggingVertexIndex == null) return;
    _vertices[_draggingVertexIndex!] = position;
    await _updateVisuals();
  }

  /// Ends the current vertex drag operation.
  Future<void> endDragVertex() async {
    _draggingVertexIndex = null;
    _setState(PolygonEditState.editing);
    await _notifyPolygonUpdated();
  }

  /// Adds a new vertex at the midpoint between the vertex at [afterIndex]
  /// and the next vertex.
  ///
  /// The new vertex is inserted at position [afterIndex + 1].
  Future<void> addMidpointVertex(int afterIndex) async {
    if (afterIndex < 0 || afterIndex >= _vertices.length) return;

    final nextIndex = (afterIndex + 1) % _vertices.length;
    final midpoint = GeoUtils.midpoint(
      _vertices[afterIndex],
      _vertices[nextIndex],
    );

    _vertices.insert(afterIndex + 1, midpoint);
    await _updateVisuals();
    await _notifyPolygonUpdated();
  }

  /// Deletes the vertex at [index].
  ///
  /// A polygon must retain at least 3 vertices. If deletion would result
  /// in fewer than 3 vertices, the operation is rejected.
  Future<bool> deleteVertex(int index) async {
    if (index < 0 || index >= _vertices.length) return false;
    if (_vertices.length <= 3) return false;

    _vertices.removeAt(index);
    await _updateVisuals();
    await _notifyPolygonUpdated();
    return true;
  }

  /// Finds the index of the nearest vertex to the given [point] within
  /// [thresholdPixels] screen distance.
  ///
  /// Returns -1 if no vertex is within the threshold.
  Future<int> findNearestVertex(
    LatLng point, {
    double thresholdPixels = 30.0,
  }) async {
    if (!_controller.isReady || _vertices.isEmpty) return -1;

    final screenPoint = await _controller.toScreenLocation(point);
    double minDist = double.infinity;
    int nearestIndex = -1;

    for (int i = 0; i < _vertices.length; i++) {
      final vertexScreen = await _controller.toScreenLocation(_vertices[i]);
      final dx = (screenPoint.x - vertexScreen.x).toDouble();
      final dy = (screenPoint.y - vertexScreen.y).toDouble();
      final dist = (dx * dx + dy * dy);

      if (dist < minDist) {
        minDist = dist;
        nearestIndex = i;
      }
    }

    // Check against threshold (squared).
    if (minDist <= thresholdPixels * thresholdPixels) {
      return nearestIndex;
    }
    return -1;
  }

  /// Finds the nearest midpoint to the given [point] and returns the
  /// index after which it would be inserted.
  ///
  /// Returns -1 if no midpoint is within the threshold.
  Future<int> findNearestMidpoint(
    LatLng point, {
    double thresholdPixels = 30.0,
  }) async {
    if (!_controller.isReady || _vertices.length < 2) return -1;

    final screenPoint = await _controller.toScreenLocation(point);
    double minDist = double.infinity;
    int nearestIndex = -1;

    for (int i = 0; i < _vertices.length; i++) {
      final nextIndex = (i + 1) % _vertices.length;
      final mid = GeoUtils.midpoint(_vertices[i], _vertices[nextIndex]);
      final midScreen = await _controller.toScreenLocation(mid);

      final dx = (screenPoint.x - midScreen.x).toDouble();
      final dy = (screenPoint.y - midScreen.y).toDouble();
      final dist = (dx * dx + dy * dy);

      if (dist < minDist) {
        minDist = dist;
        nearestIndex = i;
      }
    }

    if (minDist <= thresholdPixels * thresholdPixels) {
      return nearestIndex;
    }
    return -1;
  }

  /// Returns the polygon as a GeoJSON Feature map.
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

  /// Stops editing and removes all edit layers and sources.
  Future<void> stopEditing() async {
    if (!_isActivated) return;

    try {
      await _controller.removeLayer(_vertexLayerId);
      await _controller.removeLayer(_midpointLayerId);
      await _controller.removeLayer(_lineLayerId);
      await _controller.removeLayer(_fillLayerId);
      await _vertexSource.removeFromMap(_controller);
      await _midpointSource.removeFromMap(_controller);
      await _lineSource.removeFromMap(_controller);
      await _fillSource.removeFromMap(_controller);
    } catch (_) {
      // Layers may have already been removed.
    }

    _vertices.clear();
    _draggingVertexIndex = null;
    _isActivated = false;
    _setState(PolygonEditState.idle);
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

    // Update vertex handles.
    final vertexFeatures = _vertices
        .asMap()
        .entries
        .map((e) => GeoJsonSource.pointFeature(
              e.value,
              id: 'edit_vertex_${e.key}',
              properties: {'index': e.key},
            ))
        .toList();
    await _vertexSource.setFeatures(_controller, vertexFeatures);

    // Update midpoint handles.
    if (_vertices.length >= 2) {
      final midpointFeatures = <Map<String, dynamic>>[];
      for (int i = 0; i < _vertices.length; i++) {
        final nextIndex = (i + 1) % _vertices.length;
        final mid = GeoUtils.midpoint(_vertices[i], _vertices[nextIndex]);
        midpointFeatures.add(GeoJsonSource.pointFeature(
          mid,
          id: 'edit_midpoint_$i',
          properties: {'afterIndex': i},
        ));
      }
      await _midpointSource.setFeatures(_controller, midpointFeatures);
    } else {
      await _midpointSource.clear(_controller);
    }

    // Update outline.
    if (_vertices.length >= 2) {
      final linePoints = List<LatLng>.from(_vertices);
      if (_vertices.length >= 3) {
        linePoints.add(_vertices.first);
      }
      await _lineSource.setFeatures(_controller, [
        GeoJsonSource.lineFeature(linePoints, id: 'edit_outline'),
      ]);
    } else {
      await _lineSource.clear(_controller);
    }

    // Update fill.
    if (_vertices.length >= 3) {
      await _fillSource.setFeatures(_controller, [
        GeoJsonSource.polygonFeature(_vertices, id: 'edit_fill'),
      ]);
    } else {
      await _fillSource.clear(_controller);
    }
  }

  Future<void> _notifyPolygonUpdated() async {
    if (onPolygonUpdated != null) {
      await onPolygonUpdated!(_vertices);
    }
  }

  void _setState(PolygonEditState newState) {
    if (_state == newState) return;
    _state = newState;
    if (!_stateController.isClosed) {
      _stateController.add(_state);
    }
  }
}
