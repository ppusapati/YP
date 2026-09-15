import 'package:flutter_map_core/flutter_map_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

/// A fix, built at a metre offset from an origin so the tests read in metres
/// rather than in decimal degrees nobody can picture.
GpsPosition _fix(
  LatLng origin, {
  double east = 0,
  double north = 0,
  double accuracy = 4,
}) {
  const metresPerDegreeLat = 111320.0;
  final metresPerDegreeLng =
      metresPerDegreeLat * 0.9396926; // cos(20°), the origin below.
  return GpsPosition(
    latLng: LatLng(
      origin.latitude + north / metresPerDegreeLat,
      origin.longitude + east / metresPerDegreeLng,
    ),
    accuracyMeters: accuracy,
    timestamp: DateTime.utc(2026, 3, 14, 9, 30),
  );
}

void main() {
  // A field in the Deccan; latitude matters because a degree of longitude is
  // not a constant number of metres.
  const origin = LatLng(20.0, 77.0);

  group('dropCorner', () {
    test('records a corner and reports the polygon', () {
      final tool = BoundaryWalkTool();
      addTearDown(tool.dispose);

      tool.dropCorner(_fix(origin));
      tool.dropCorner(_fix(origin, east: 100));
      tool.dropCorner(_fix(origin, east: 100, north: 100));

      expect(tool.points, hasLength(3));
      expect(tool.hasUsablePolygon, isTrue);
    });

    test('refuses a fix that is not accurate enough to be a boundary', () async {
      final tool = BoundaryWalkTool(accuracyThresholdMeters: 15);
      addTearDown(tool.dispose);

      final rejected = expectLater(
        tool.rejections,
        emits(BoundaryRejection.poorAccuracy),
      );

      // What a phone reports under tree cover. A boundary built from these is
      // wrong by more than the width of the headland and looks exactly as
      // convincing as a good one.
      final point = tool.dropCorner(_fix(origin, accuracy: 42));

      expect(point, isNull);
      expect(tool.points, isEmpty);
      await rejected;
    });

    test('accepts a fix exactly at the threshold', () {
      final tool = BoundaryWalkTool(accuracyThresholdMeters: 15);
      addTearDown(tool.dispose);

      expect(tool.dropCorner(_fix(origin, accuracy: 15)), isNotNull);
    });

    test('does not enforce spacing, because a corner is where you stand', () {
      // Two corners of a narrow headland can legitimately be a metre apart.
      final tool = BoundaryWalkTool(minPointSpacingMeters: 10);
      addTearDown(tool.dispose);

      tool.dropCorner(_fix(origin));
      tool.dropCorner(_fix(origin, east: 1));

      expect(tool.points, hasLength(2));
    });

    test('a null position records nothing rather than throwing', () {
      // The UI calls this with whatever the GPS tool currently holds, which is
      // null before the first fix.
      final tool = BoundaryWalkTool();
      addTearDown(tool.dispose);

      expect(tool.dropCorner(null), isNull);
      expect(tool.points, isEmpty);
    });
  });

  group('undo and clear', () {
    test('undo drops the last point only', () {
      final tool = BoundaryWalkTool();
      addTearDown(tool.dispose);

      tool.dropCorner(_fix(origin));
      tool.dropCorner(_fix(origin, east: 50));
      tool.undo();

      expect(tool.points, hasLength(1));
    });

    test('undo on an empty walk is a no-op', () {
      final tool = BoundaryWalkTool();
      addTearDown(tool.dispose);

      tool.undo();

      expect(tool.points, isEmpty);
    });

    test('clear discards the walk', () {
      final tool = BoundaryWalkTool();
      addTearDown(tool.dispose);

      tool.dropCorner(_fix(origin));
      tool.dropCorner(_fix(origin, east: 50));
      tool.clear();

      expect(tool.points, isEmpty);
      expect(tool.hasUsablePolygon, isFalse);
    });
  });

  group('measurements', () {
    test('reports the area of a walked square', () {
      final tool = BoundaryWalkTool();
      addTearDown(tool.dispose);

      // 100 m on a side: one hectare.
      tool.dropCorner(_fix(origin));
      tool.dropCorner(_fix(origin, east: 100));
      tool.dropCorner(_fix(origin, east: 100, north: 100));
      tool.dropCorner(_fix(origin, north: 100));

      expect(tool.areaHectares, closeTo(1.0, 0.02));
    });

    test('area is zero until there is a polygon', () {
      final tool = BoundaryWalkTool();
      addTearDown(tool.dispose);

      tool.dropCorner(_fix(origin));
      tool.dropCorner(_fix(origin, east: 100));

      expect(tool.areaHectares, 0);
      expect(tool.hasUsablePolygon, isFalse);
    });

    test('reports the worst fix, so a boundary carries its own confidence', () {
      final tool = BoundaryWalkTool();
      addTearDown(tool.dispose);

      tool.dropCorner(_fix(origin, accuracy: 3));
      tool.dropCorner(_fix(origin, east: 100, accuracy: 11));
      tool.dropCorner(_fix(origin, north: 100, accuracy: 5));

      expect(tool.worstAccuracyMeters, 11);
    });

    test('reports the distance walked', () {
      final tool = BoundaryWalkTool();
      addTearDown(tool.dispose);

      tool.dropCorner(_fix(origin));
      tool.dropCorner(_fix(origin, east: 100));
      tool.dropCorner(_fix(origin, east: 100, north: 100));

      expect(tool.walkedMeters, closeTo(200, 1));
    });
  });

  group('close', () {
    test('returns an open ring, not a repeated first point', () {
      final tool = BoundaryWalkTool(simplifyToleranceMeters: 0);
      addTearDown(tool.dispose);

      tool.dropCorner(_fix(origin));
      tool.dropCorner(_fix(origin, east: 100));
      tool.dropCorner(_fix(origin, east: 100, north: 100));

      final ring = tool.close();

      expect(ring, hasLength(3));
      expect(ring.first, isNot(ring.last));
    });

    test('refuses to make a polygon out of two points', () {
      // A two-point "field" would save with no area and look like a real
      // record.
      final tool = BoundaryWalkTool();
      addTearDown(tool.dispose);

      tool.dropCorner(_fix(origin));
      tool.dropCorner(_fix(origin, east: 100));

      expect(tool.close(), isEmpty);
    });

    test('thins a walked edge back to its corners', () {
      final tool = BoundaryWalkTool(simplifyToleranceMeters: 2);
      addTearDown(tool.dispose);

      // Someone walking a straight 100 m edge, a fix every 10 m, wandering
      // half a metre either side of the line as people do.
      for (var i = 0; i <= 10; i++) {
        tool.dropCorner(_fix(origin, east: i * 10, north: i.isEven ? 0.4 : -0.4));
      }
      tool.dropCorner(_fix(origin, east: 100, north: 100));

      final ring = tool.close();

      expect(
        ring.length,
        lessThan(6),
        reason: 'a straight edge does not need eleven vertices',
      );
      expect(ring.length, greaterThanOrEqualTo(3));
    });

    test('keeps a real corner that simplification must not cut', () {
      final tool = BoundaryWalkTool(simplifyToleranceMeters: 2);
      addTearDown(tool.dispose);

      tool.dropCorner(_fix(origin));
      tool.dropCorner(_fix(origin, east: 50));
      tool.dropCorner(_fix(origin, east: 100, north: 60)); // the corner
      tool.dropCorner(_fix(origin, east: 150));
      tool.dropCorner(_fix(origin, east: 200));

      final ring = tool.close();

      // The 60 m deviation is far outside the 2 m tolerance, so the vertex
      // has to survive: cutting it would quietly redraw the field.
      expect(
        ring.any((p) => (p.latitude - origin.latitude) > 0.0004),
        isTrue,
      );
    });
  });

  group('simplify', () {
    test('leaves a two-point line alone', () {
      final line = [const LatLng(20, 77), const LatLng(20.001, 77.001)];
      expect(BoundaryWalkTool.simplify(line, 5), line);
    });

    test('a zero tolerance changes nothing', () {
      final line = [
        const LatLng(20, 77),
        const LatLng(20.0001, 77.00005),
        const LatLng(20.0002, 77.0001),
      ];
      expect(BoundaryWalkTool.simplify(line, 0), hasLength(3));
    });

    test('measures in metres, not degrees', () {
      // The same shape at two latitudes must simplify the same way. In degrees
      // it would not: a degree of longitude is 111 km at the equator and 71 km
      // in the Punjab, so a degree-based tolerance means something different
      // in every field.
      List<LatLng> zigzag(double lat) => [
            LatLng(lat, 77.0),
            LatLng(lat + 0.000005, 77.0005),
            LatLng(lat, 77.001),
          ];

      expect(
        BoundaryWalkTool.simplify(zigzag(1.0), 3).length,
        BoundaryWalkTool.simplify(zigzag(60.0), 3).length,
      );
    });
  });
}
