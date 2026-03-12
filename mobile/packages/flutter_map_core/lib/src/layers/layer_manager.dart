import 'dart:async';

import '../engine/map_controller_wrapper.dart';
import 'map_layer.dart';

/// Manages the lifecycle and state of all map layers.
///
/// [LayerManager] provides a centralized API for adding, removing, toggling,
/// reordering, and adjusting the opacity of map layers. It maintains an
/// ordered registry of [MapLayer] instances and synchronizes their state
/// with the underlying map controller.
class LayerManager {
  final MapControllerWrapper _controller;

  /// Internal ordered list of managed layers.
  final List<MapLayer> _layers = [];

  /// Stream controller for broadcasting layer state changes.
  final StreamController<List<MapLayer>> _layerChangesController =
      StreamController<List<MapLayer>>.broadcast();

  /// Creates a new [LayerManager] bound to the given [controller].
  LayerManager(this._controller);

  /// Returns an unmodifiable snapshot of the current layers, sorted by zIndex.
  List<MapLayer> get layers => List.unmodifiable(
        List<MapLayer>.from(_layers)..sort((a, b) => a.zIndex.compareTo(b.zIndex)),
      );

  /// A stream that emits the updated layer list whenever a change occurs.
  Stream<List<MapLayer>> get layerChanges => _layerChangesController.stream;

  /// Returns the layer with the given [layerId], or `null` if not found.
  MapLayer? getLayer(String layerId) {
    final index = _indexOfLayer(layerId);
    return index >= 0 ? _layers[index] : null;
  }

  /// Returns all layers matching the given [type].
  List<MapLayer> getLayersByType(MapLayerType type) {
    return _layers.where((l) => l.type == type).toList();
  }

  /// Adds a new layer to the map.
  ///
  /// The layer must have a unique [MapLayer.id]. If a layer with the same
  /// ID already exists, this method does nothing.
  ///
  /// [addSourceAndLayer] is an optional callback that performs the actual
  /// MapLibre source/layer addition. If not provided, only the layer
  /// metadata is registered (useful when the actual map layer is added
  /// separately by vector/raster layer classes).
  Future<void> addLayer(
    MapLayer layer, {
    Future<void> Function(MapControllerWrapper controller)? addSourceAndLayer,
  }) async {
    if (_indexOfLayer(layer.id) >= 0) return;

    _layers.add(layer);

    if (addSourceAndLayer != null) {
      await addSourceAndLayer(_controller);
    }

    _notifyChange();
  }

  /// Removes a layer from the map by its [layerId].
  ///
  /// [removeSourceAndLayer] is an optional callback that performs the actual
  /// MapLibre source/layer removal.
  Future<void> removeLayer(
    String layerId, {
    Future<void> Function(MapControllerWrapper controller)? removeSourceAndLayer,
  }) async {
    final index = _indexOfLayer(layerId);
    if (index < 0) return;

    if (removeSourceAndLayer != null) {
      await removeSourceAndLayer(_controller);
    }

    _layers.removeAt(index);
    _notifyChange();
  }

  /// Toggles the visibility of a layer.
  ///
  /// If the layer is visible, it will be hidden, and vice versa.
  Future<void> toggleLayer(String layerId) async {
    final index = _indexOfLayer(layerId);
    if (index < 0) return;

    final layer = _layers[index];
    final newVisible = !layer.visible;
    _layers[index] = layer.copyWith(visible: newVisible);

    await _controller.setLayerVisibility(
      layer.styleLayerId ?? layer.id,
      newVisible,
    );

    _notifyChange();
  }

  /// Sets the visibility of a specific layer.
  Future<void> setLayerVisibility(String layerId, bool visible) async {
    final index = _indexOfLayer(layerId);
    if (index < 0) return;

    final layer = _layers[index];
    if (layer.visible == visible) return;

    _layers[index] = layer.copyWith(visible: visible);

    await _controller.setLayerVisibility(
      layer.styleLayerId ?? layer.id,
      visible,
    );

    _notifyChange();
  }

  /// Sets the opacity of a layer.
  ///
  /// [opacity] must be between 0.0 and 1.0. The opacity is stored in the
  /// layer metadata and applied to the map style.
  Future<void> setOpacity(String layerId, double opacity) async {
    assert(opacity >= 0.0 && opacity <= 1.0, 'Opacity must be between 0.0 and 1.0');

    final index = _indexOfLayer(layerId);
    if (index < 0) return;

    final layer = _layers[index];
    _layers[index] = layer.copyWith(opacity: opacity.clamp(0.0, 1.0));

    _notifyChange();
  }

  /// Reorders layers by moving the layer at [oldIndex] to [newIndex].
  ///
  /// This updates zIndex values to reflect the new order. The actual
  /// MapLibre layer ordering is managed via the layer insertion order
  /// and below-layer references.
  void reorderLayers(int oldIndex, int newIndex) {
    if (oldIndex < 0 ||
        oldIndex >= _layers.length ||
        newIndex < 0 ||
        newIndex >= _layers.length) {
      return;
    }

    final layer = _layers.removeAt(oldIndex);
    _layers.insert(newIndex, layer);

    // Reassign zIndex values based on new list order.
    for (int i = 0; i < _layers.length; i++) {
      _layers[i] = _layers[i].copyWith(zIndex: i);
    }

    _notifyChange();
  }

  /// Moves a layer to a specific z-index position.
  void setLayerZIndex(String layerId, int zIndex) {
    final index = _indexOfLayer(layerId);
    if (index < 0) return;

    _layers[index] = _layers[index].copyWith(zIndex: zIndex);
    _notifyChange();
  }

  /// Updates the metadata for a layer.
  void updateLayerMetadata(String layerId, Map<String, dynamic> metadata) {
    final index = _indexOfLayer(layerId);
    if (index < 0) return;

    final existing = Map<String, dynamic>.from(_layers[index].metadata);
    existing.addAll(metadata);
    _layers[index] = _layers[index].copyWith(metadata: existing);
    _notifyChange();
  }

  /// Removes all layers.
  Future<void> clearAll({
    Future<void> Function(MapControllerWrapper controller, MapLayer layer)?
        removeSourceAndLayer,
  }) async {
    if (removeSourceAndLayer != null) {
      for (final layer in List<MapLayer>.from(_layers)) {
        await removeSourceAndLayer(_controller, layer);
      }
    }

    _layers.clear();
    _notifyChange();
  }

  /// Returns the number of managed layers.
  int get layerCount => _layers.length;

  /// Whether a layer with the given [layerId] exists.
  bool hasLayer(String layerId) => _indexOfLayer(layerId) >= 0;

  /// Disposes of the layer manager and closes the stream.
  void dispose() {
    _layerChangesController.close();
  }

  int _indexOfLayer(String layerId) {
    for (int i = 0; i < _layers.length; i++) {
      if (_layers[i].id == layerId) return i;
    }
    return -1;
  }

  void _notifyChange() {
    if (!_layerChangesController.isClosed) {
      _layerChangesController.add(layers);
    }
  }
}
