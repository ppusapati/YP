import 'dart:convert';

import 'package:maplibre_gl/maplibre_gl.dart';

import '../engine/map_controller_wrapper.dart';

/// Manages GeoJSON data sources for the map.
///
/// Provides methods to create, update, and remove GeoJSON sources that
/// can be used by vector layers (fill, line, circle, symbol).
class GeoJsonSource {
  /// The unique identifier for this source on the map.
  final String sourceId;

  /// The current GeoJSON data as a map.
  Map<String, dynamic> _data;

  /// Whether this source has been added to the map.
  bool _isAdded = false;

  /// Creates a new [GeoJsonSource] with the given [sourceId] and optional
  /// initial [data].
  GeoJsonSource({
    required this.sourceId,
    Map<String, dynamic>? data,
  }) : _data = data ?? _emptyFeatureCollection();

  /// Returns the current GeoJSON data.
  Map<String, dynamic> get data => _data;

  /// Whether this source has been added to the map.
  bool get isAdded => _isAdded;

  /// Adds this source to the map via the given [controller].
  ///
  /// Throws [StateError] if the source has already been added.
  Future<void> addToMap(MapControllerWrapper controller) async {
    if (_isAdded) {
      throw StateError('GeoJsonSource "$sourceId" is already added to the map.');
    }
    await controller.addGeoJsonSource(sourceId, _data);
    _isAdded = true;
  }

  /// Updates the GeoJSON data for this source on the map.
  ///
  /// [newData] should be a valid GeoJSON object (FeatureCollection, Feature,
  /// or Geometry).
  Future<void> update(
    MapControllerWrapper controller,
    Map<String, dynamic> newData,
  ) async {
    _data = newData;
    if (_isAdded) {
      await controller.setGeoJsonSource(sourceId, _data);
    }
  }

  /// Replaces the features in the source with the given list of GeoJSON
  /// Feature maps.
  Future<void> setFeatures(
    MapControllerWrapper controller,
    List<Map<String, dynamic>> features,
  ) async {
    final collection = {
      'type': 'FeatureCollection',
      'features': features,
    };
    await update(controller, collection);
  }

  /// Adds a single feature to the existing feature collection.
  Future<void> addFeature(
    MapControllerWrapper controller,
    Map<String, dynamic> feature,
  ) async {
    final features =
        List<Map<String, dynamic>>.from(_data['features'] as List? ?? []);
    features.add(feature);
    await setFeatures(controller, features);
  }

  /// Removes a feature by its `id` property from the feature collection.
  Future<void> removeFeatureById(
    MapControllerWrapper controller,
    String featureId,
  ) async {
    final features =
        List<Map<String, dynamic>>.from(_data['features'] as List? ?? []);
    features.removeWhere((f) => f['id'] == featureId);
    await setFeatures(controller, features);
  }

  /// Clears all features from this source.
  Future<void> clear(MapControllerWrapper controller) async {
    await update(controller, _emptyFeatureCollection());
  }

  /// Removes this source from the map.
  Future<void> removeFromMap(MapControllerWrapper controller) async {
    if (!_isAdded) return;
    await controller.removeSource(sourceId);
    _isAdded = false;
  }

  /// Creates a GeoJSON Feature from a polygon defined by a list of vertices.
  ///
  /// The polygon ring is automatically closed if the first and last points
  /// differ.
  static Map<String, dynamic> polygonFeature(
    List<LatLng> vertices, {
    String? id,
    Map<String, dynamic>? properties,
  }) {
    final ring = vertices
        .map((v) => [v.longitude, v.latitude])
        .toList();

    // Close the ring if necessary.
    if (ring.isNotEmpty &&
        (ring.first[0] != ring.last[0] || ring.first[1] != ring.last[1])) {
      ring.add(List.from(ring.first));
    }

    return {
      'type': 'Feature',
      if (id != null) 'id': id,
      'properties': properties ?? {},
      'geometry': {
        'type': 'Polygon',
        'coordinates': [ring],
      },
    };
  }

  /// Creates a GeoJSON Feature from a line defined by a list of coordinates.
  static Map<String, dynamic> lineFeature(
    List<LatLng> points, {
    String? id,
    Map<String, dynamic>? properties,
  }) {
    final coords = points
        .map((p) => [p.longitude, p.latitude])
        .toList();

    return {
      'type': 'Feature',
      if (id != null) 'id': id,
      'properties': properties ?? {},
      'geometry': {
        'type': 'LineString',
        'coordinates': coords,
      },
    };
  }

  /// Creates a GeoJSON Feature from a single point.
  static Map<String, dynamic> pointFeature(
    LatLng point, {
    String? id,
    Map<String, dynamic>? properties,
  }) {
    return {
      'type': 'Feature',
      if (id != null) 'id': id,
      'properties': properties ?? {},
      'geometry': {
        'type': 'Point',
        'coordinates': [point.longitude, point.latitude],
      },
    };
  }

  /// Creates a GeoJSON Feature from a multi-point geometry.
  static Map<String, dynamic> multiPointFeature(
    List<LatLng> points, {
    String? id,
    Map<String, dynamic>? properties,
  }) {
    final coords = points
        .map((p) => [p.longitude, p.latitude])
        .toList();

    return {
      'type': 'Feature',
      if (id != null) 'id': id,
      'properties': properties ?? {},
      'geometry': {
        'type': 'MultiPoint',
        'coordinates': coords,
      },
    };
  }

  /// Creates an empty GeoJSON FeatureCollection.
  static Map<String, dynamic> _emptyFeatureCollection() {
    return {
      'type': 'FeatureCollection',
      'features': <Map<String, dynamic>>[],
    };
  }

  /// Creates a FeatureCollection from a list of features.
  static Map<String, dynamic> featureCollection(
    List<Map<String, dynamic>> features,
  ) {
    return {
      'type': 'FeatureCollection',
      'features': features,
    };
  }

  /// Parses a GeoJSON string into a map.
  static Map<String, dynamic> parseGeoJson(String geoJsonString) {
    return json.decode(geoJsonString) as Map<String, dynamic>;
  }
}
