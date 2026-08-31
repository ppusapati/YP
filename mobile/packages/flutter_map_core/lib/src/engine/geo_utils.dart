import 'dart:math';

import 'package:maplibre_gl/maplibre_gl.dart';

/// Utility class providing common geospatial calculations.
///
/// Includes methods for distance, area, bearing, centroid, and
/// point-in-polygon testing. All calculations use WGS84 coordinates.
class GeoUtils {
  GeoUtils._();

  /// Earth's mean radius in meters (WGS84).
  static const double earthRadiusMeters = 6371008.8;

  /// Converts degrees to radians.
  static double degreesToRadians(double degrees) => degrees * pi / 180.0;

  /// Converts radians to degrees.
  static double radiansToDegrees(double radians) => radians * 180.0 / pi;

  /// Calculates the great-circle distance between two points using the
  /// Haversine formula.
  ///
  /// Returns the distance in meters.
  ///
  /// ```dart
  /// final distance = GeoUtils.haversineDistance(
  ///   LatLng(40.7128, -74.0060), // New York
  ///   LatLng(51.5074, -0.1278),  // London
  /// );
  /// ```
  static double haversineDistance(LatLng from, LatLng to) {
    final lat1 = degreesToRadians(from.latitude);
    final lat2 = degreesToRadians(to.latitude);
    final deltaLat = degreesToRadians(to.latitude - from.latitude);
    final deltaLng = degreesToRadians(to.longitude - from.longitude);

    final a = sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1) * cos(lat2) * sin(deltaLng / 2) * sin(deltaLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusMeters * c;
  }

  /// Calculates the total distance along a polyline defined by a list of
  /// coordinates.
  ///
  /// Returns the total distance in meters.
  static double polylineDistance(List<LatLng> points) {
    if (points.length < 2) return 0.0;

    double total = 0.0;
    for (int i = 0; i < points.length - 1; i++) {
      total += haversineDistance(points[i], points[i + 1]);
    }
    return total;
  }

  /// Calculates the area of a polygon using the Shoelace formula adapted
  /// for geographic coordinates.
  ///
  /// Returns the area in square meters. The polygon is defined by a list of
  /// vertices. The polygon is automatically closed if the first and last
  /// points differ.
  ///
  /// Uses the spherical excess method for geodesic accuracy on large polygons.
  static double polygonArea(List<LatLng> vertices) {
    if (vertices.length < 3) return 0.0;

    // Ensure polygon is closed.
    final points = List<LatLng>.from(vertices);
    if (points.first.latitude != points.last.latitude ||
        points.first.longitude != points.last.longitude) {
      points.add(points.first);
    }

    // Use the Shoelace formula projected to a local flat surface.
    // For better accuracy on large polygons, we use the spherical excess
    // method.
    double area = 0.0;
    final n = points.length;

    for (int i = 0; i < n - 1; i++) {
      final p1 = points[i];
      final p2 = points[(i + 1) % n];

      final lat1 = degreesToRadians(p1.latitude);
      final lat2 = degreesToRadians(p2.latitude);
      final lng1 = degreesToRadians(p1.longitude);
      final lng2 = degreesToRadians(p2.longitude);

      // Spherical excess formula component.
      area += (lng2 - lng1) * (2 + sin(lat1) + sin(lat2));
    }

    area = (area * earthRadiusMeters * earthRadiusMeters / 2.0).abs();
    return area;
  }

  /// Converts polygon area from square meters to hectares.
  ///
  /// Returns the area in hectares (1 hectare = 10,000 m^2).
  static double polygonAreaHectares(List<LatLng> vertices) {
    return polygonArea(vertices) / 10000.0;
  }

  /// Converts polygon area from square meters to acres.
  ///
  /// Returns the area in acres (1 acre = 4046.8564224 m^2).
  static double polygonAreaAcres(List<LatLng> vertices) {
    return polygonArea(vertices) / 4046.8564224;
  }

  /// Calculates the initial bearing from one point to another.
  ///
  /// Returns the bearing in degrees (0-360), where 0 is north.
  static double bearing(LatLng from, LatLng to) {
    final lat1 = degreesToRadians(from.latitude);
    final lat2 = degreesToRadians(to.latitude);
    final deltaLng = degreesToRadians(to.longitude - from.longitude);

    final y = sin(deltaLng) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltaLng);

    final bearing = radiansToDegrees(atan2(y, x));
    return (bearing + 360) % 360;
  }

  /// Calculates the centroid (geometric center) of a polygon.
  ///
  /// Returns the centroid as a [LatLng] coordinate. The polygon is defined
  /// by a list of vertices.
  static LatLng polygonCentroid(List<LatLng> vertices) {
    if (vertices.isEmpty) {
      return const LatLng(0.0, 0.0);
    }
    if (vertices.length == 1) {
      return vertices.first;
    }
    if (vertices.length == 2) {
      return LatLng(
        (vertices[0].latitude + vertices[1].latitude) / 2,
        (vertices[0].longitude + vertices[1].longitude) / 2,
      );
    }

    // Ensure polygon is closed.
    final points = List<LatLng>.from(vertices);
    if (points.first.latitude != points.last.latitude ||
        points.first.longitude != points.last.longitude) {
      points.add(points.first);
    }

    double cx = 0.0;
    double cy = 0.0;
    double signedArea = 0.0;

    for (int i = 0; i < points.length - 1; i++) {
      final x0 = points[i].longitude;
      final y0 = points[i].latitude;
      final x1 = points[i + 1].longitude;
      final y1 = points[i + 1].latitude;

      final a = x0 * y1 - x1 * y0;
      signedArea += a;
      cx += (x0 + x1) * a;
      cy += (y0 + y1) * a;
    }

    signedArea *= 0.5;

    if (signedArea.abs() < 1e-12) {
      // Degenerate polygon: return simple average.
      double avgLat = 0;
      double avgLng = 0;
      for (final p in vertices) {
        avgLat += p.latitude;
        avgLng += p.longitude;
      }
      return LatLng(avgLat / vertices.length, avgLng / vertices.length);
    }

    cx /= (6.0 * signedArea);
    cy /= (6.0 * signedArea);

    return LatLng(cy, cx);
  }

  /// Tests whether a point lies inside a polygon using the ray casting
  /// algorithm.
  ///
  /// Returns `true` if the point is inside the polygon, `false` otherwise.
  /// Points exactly on the boundary may return either value.
  static bool pointInPolygon(LatLng point, List<LatLng> polygon) {
    if (polygon.length < 3) return false;

    bool inside = false;
    final n = polygon.length;

    for (int i = 0, j = n - 1; i < n; j = i++) {
      final xi = polygon[i].longitude;
      final yi = polygon[i].latitude;
      final xj = polygon[j].longitude;
      final yj = polygon[j].latitude;

      final intersect = ((yi > point.latitude) != (yj > point.latitude)) &&
          (point.longitude <
              (xj - xi) * (point.latitude - yi) / (yj - yi) + xi);

      if (intersect) {
        inside = !inside;
      }
    }

    return inside;
  }

  /// Calculates the midpoint between two geographic coordinates.
  static LatLng midpoint(LatLng from, LatLng to) {
    final lat1 = degreesToRadians(from.latitude);
    final lng1 = degreesToRadians(from.longitude);
    final lat2 = degreesToRadians(to.latitude);
    final lng2 = degreesToRadians(to.longitude);

    final dLng = lng2 - lng1;

    final bx = cos(lat2) * cos(dLng);
    final by = cos(lat2) * sin(dLng);

    final lat =
        atan2(sin(lat1) + sin(lat2), sqrt((cos(lat1) + bx) * (cos(lat1) + bx) + by * by));
    final lng = lng1 + atan2(by, cos(lat1) + bx);

    return LatLng(radiansToDegrees(lat), radiansToDegrees(lng));
  }

  /// Calculates the bounding box that contains all given points.
  ///
  /// Returns `null` if the list is empty.
  static LatLngBounds? boundingBox(List<LatLng> points) {
    if (points.isEmpty) return null;

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points) {
      minLat = min(minLat, point.latitude);
      maxLat = max(maxLat, point.latitude);
      minLng = min(minLng, point.longitude);
      maxLng = max(maxLng, point.longitude);
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  /// Computes a destination point given a start point, bearing, and distance.
  ///
  /// [from] is the starting coordinate, [bearingDeg] is the bearing in degrees,
  /// and [distanceMeters] is the distance in meters.
  static LatLng destinationPoint(
    LatLng from,
    double bearingDeg,
    double distanceMeters,
  ) {
    final lat1 = degreesToRadians(from.latitude);
    final lng1 = degreesToRadians(from.longitude);
    final brng = degreesToRadians(bearingDeg);
    final d = distanceMeters / earthRadiusMeters;

    final lat2 =
        asin(sin(lat1) * cos(d) + cos(lat1) * sin(d) * cos(brng));
    final lng2 = lng1 +
        atan2(
          sin(brng) * sin(d) * cos(lat1),
          cos(d) - sin(lat1) * sin(lat2),
        );

    return LatLng(radiansToDegrees(lat2), radiansToDegrees(lng2));
  }

  /// Formats a distance value to a human-readable string.
  ///
  /// Distances under 1000 meters are shown in meters, otherwise in kilometers.
  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(1)} m';
    }
    return '${(meters / 1000).toStringAsFixed(2)} km';
  }

  /// Formats an area value to a human-readable string.
  ///
  /// Areas under 10,000 m^2 are shown in square meters, otherwise in hectares.
  static String formatArea(double squareMeters) {
    if (squareMeters < 10000) {
      return '${squareMeters.toStringAsFixed(1)} m\u00B2';
    }
    return '${(squareMeters / 10000).toStringAsFixed(2)} ha';
  }
}
