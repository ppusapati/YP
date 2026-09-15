import 'dart:async';
import 'dart:math';

import 'package:maplibre_gl/maplibre_gl.dart';

import '../engine/geo_utils.dart';
import 'gps_location_tool.dart';

/// How boundary points are collected while walking a field.
enum BoundaryWalkMode {
  /// The walker records a vertex only when asked to.
  ///
  /// Right for a field with straight edges and identifiable corners, which is
  /// most of them: four taps beat four hundred samples, and each one is taken
  /// while standing still, which is when a GPS fix is at its best.
  corners,

  /// The walker records the track continuously as the perimeter is walked.
  ///
  /// Right for an irregular boundary — a field that follows a stream or a
  /// hedgerow. Points are thinned as they arrive, because a ten-minute walk at
  /// one fix a second is six hundred vertices describing a shape that needs
  /// twenty.
  continuous,
}

/// Why a GPS fix was not used as a boundary point.
enum BoundaryRejection {
  /// The fix was less accurate than the walk requires.
  ///
  /// This is the one that matters. A phone under tree cover regularly reports
  /// 30–50 m, and a boundary drawn from those fixes is wrong by more than the
  /// width of the headland — while looking exactly as convincing as a good
  /// one.
  poorAccuracy,

  /// The fix was too close to the previous point to add anything.
  tooClose,
}

/// A vertex recorded while walking a boundary, with the fix it came from.
class BoundaryPoint {
  const BoundaryPoint({
    required this.latLng,
    required this.accuracyMeters,
    required this.recordedAt,
  });

  final LatLng latLng;

  /// Horizontal accuracy of the fix, in metres. Kept per point rather than
  /// per walk so the weakest corner can be found and re-taken.
  final double accuracyMeters;

  final DateTime recordedAt;
}

/// Builds a field boundary from GPS fixes taken while walking the perimeter.
///
/// Drawing a field by tapping a map works when you can see the field on the
/// map. On a phone in the field, at a zoom where the whole field fits, a
/// fingertip covers several metres — and satellite imagery is often months old
/// and cloud-streaked. Walking the edge is how a boundary gets recorded
/// accurately, and it is the one thing the field editor could not do.
///
/// The tool does three things a naive "append every fix" loop does not:
///
///   * **Gates on accuracy.** A fix worse than [accuracyThresholdMeters] is
///     refused and reported. A boundary silently built from 40 m fixes is the
///     failure worth preventing, because nothing downstream can detect it.
///   * **Thins as it goes.** In [BoundaryWalkMode.continuous] a fix closer
///     than [minPointSpacingMeters] to the last one is dropped, so standing
///     still does not pile up hundreds of coincident vertices.
///   * **Simplifies on close.** [close] runs Douglas–Peucker over the walk, so
///     a walked rectangle comes back as roughly four corners rather than as
///     the raw track.
///
/// Nothing here touches the map; [GpsLocationTool] owns the fixes and the
/// on-map position marker, and this consumes its stream. That split is what
/// lets the walk be tested without a map or a device.
class BoundaryWalkTool {
  BoundaryWalkTool({
    this.mode = BoundaryWalkMode.corners,
    this.accuracyThresholdMeters = 15.0,
    this.minPointSpacingMeters = 3.0,
    this.simplifyToleranceMeters = 1.5,
  });

  /// How points are collected.
  BoundaryWalkMode mode;

  /// The worst fix accuracy accepted as a boundary point, in metres.
  ///
  /// 15 m is deliberately generous: a stricter gate on a cloudy day under
  /// trees refuses everything, and a farmer who cannot record a boundary at
  /// all is worse served than one who records a rough boundary and is told it
  /// is rough.
  double accuracyThresholdMeters;

  /// Minimum distance between consecutive points in continuous mode, in metres.
  double minPointSpacingMeters;

  /// Douglas–Peucker tolerance applied when the walk is closed, in metres.
  double simplifyToleranceMeters;

  final List<BoundaryPoint> _points = [];
  StreamSubscription<GpsPosition>? _subscription;
  bool _walking = false;

  final _pointsController = StreamController<List<BoundaryPoint>>.broadcast();
  final _rejectionController = StreamController<BoundaryRejection>.broadcast();

  /// Points recorded so far, in the order they were walked.
  List<BoundaryPoint> get points => List.unmodifiable(_points);

  /// The boundary as plain coordinates.
  List<LatLng> get polygon => _points.map((p) => p.latLng).toList();

  /// Whether a walk is in progress.
  bool get isWalking => _walking;

  /// Emits the full point list whenever it changes, for a live map overlay.
  Stream<List<BoundaryPoint>> get pointsStream => _pointsController.stream;

  /// Emits when a fix was not used, so the UI can say why.
  ///
  /// Silence here would be the worst outcome: someone walks a whole field
  /// under tree cover, nothing is recorded, and the screen looks the same as
  /// if it were working.
  Stream<BoundaryRejection> get rejections => _rejectionController.stream;

  /// Whether enough points exist to make a polygon at all.
  bool get hasUsablePolygon => _points.length >= 3;

  /// The walk's area in hectares, or 0 while it is not yet a polygon.
  double get areaHectares =>
      hasUsablePolygon ? GeoUtils.polygonAreaHectares(polygon) : 0.0;

  /// Distance walked so far, in metres.
  double get walkedMeters => GeoUtils.polylineDistance(polygon);

  /// The worst fix accuracy among the recorded points, in metres.
  ///
  /// Surfaced so the boundary can be reported with the confidence it deserves
  /// rather than as an exact figure.
  double get worstAccuracyMeters => _points.isEmpty
      ? 0.0
      : _points.map((p) => p.accuracyMeters).reduce(max);

  /// Starts a walk, consuming fixes from [gps].
  ///
  /// Existing points are kept, so a walk interrupted by a phone call resumes
  /// rather than starting over.
  void start(GpsLocationTool gps) {
    if (_walking) return;
    _walking = true;

    _subscription = gps.positionStream.listen((position) {
      if (mode == BoundaryWalkMode.continuous) {
        _offer(position);
      }
    });
  }

  /// Records the current position as a boundary vertex.
  ///
  /// Used in [BoundaryWalkMode.corners], where the walker stands at a corner
  /// and drops a point. Returns the point, or null when the fix was refused —
  /// the reason is on [rejections].
  BoundaryPoint? dropCorner(GpsPosition? position) {
    if (position == null) return null;
    return _offer(position, enforceSpacing: false);
  }

  /// Removes the last recorded point.
  void undo() {
    if (_points.isEmpty) return;
    _points.removeLast();
    _emit();
  }

  /// Discards the whole walk.
  void clear() {
    if (_points.isEmpty) return;
    _points.clear();
    _emit();
  }

  /// Ends the walk and returns the finished boundary.
  ///
  /// The ring is simplified and returned open — first point not repeated as
  /// the last — because that is how [GeoUtils.polygonArea] and the field
  /// entity both expect a polygon. Returns an empty list when fewer than
  /// three points were recorded, rather than a degenerate shape that would
  /// save as a field with no area.
  List<LatLng> close() {
    _walking = false;
    _subscription?.cancel();
    _subscription = null;

    if (!hasUsablePolygon) return const [];

    final simplified = simplify(polygon, simplifyToleranceMeters);

    // Simplification can take a nearly-closed walk below three points; the
    // raw ring is a better answer than nothing.
    return simplified.length >= 3 ? simplified : polygon;
  }

  /// Releases the position subscription and the streams.
  void dispose() {
    _subscription?.cancel();
    _pointsController.close();
    _rejectionController.close();
  }

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  BoundaryPoint? _offer(GpsPosition position, {bool enforceSpacing = true}) {
    if (position.accuracyMeters > accuracyThresholdMeters) {
      _reject(BoundaryRejection.poorAccuracy);
      return null;
    }

    if (enforceSpacing && _points.isNotEmpty) {
      final gap = GeoUtils.haversineDistance(
        _points.last.latLng,
        position.latLng,
      );
      if (gap < minPointSpacingMeters) {
        _reject(BoundaryRejection.tooClose);
        return null;
      }
    }

    final point = BoundaryPoint(
      latLng: position.latLng,
      accuracyMeters: position.accuracyMeters,
      recordedAt: position.timestamp,
    );
    _points.add(point);
    _emit();
    return point;
  }

  void _reject(BoundaryRejection reason) {
    if (!_rejectionController.isClosed) _rejectionController.add(reason);
  }

  void _emit() {
    if (!_pointsController.isClosed) _pointsController.add(points);
  }

  /// Douglas–Peucker simplification with a tolerance in metres.
  ///
  /// Exposed because the same thinning is useful on a boundary that arrived
  /// from anywhere — an imported GPX track, say — not only on a fresh walk.
  static List<LatLng> simplify(List<LatLng> points, double toleranceMeters) {
    if (points.length <= 2 || toleranceMeters <= 0) return List.of(points);

    final keep = List<bool>.filled(points.length, false);
    keep[0] = true;
    keep[points.length - 1] = true;
    _simplifySegment(points, 0, points.length - 1, toleranceMeters, keep);

    final out = <LatLng>[];
    for (var i = 0; i < points.length; i++) {
      if (keep[i]) out.add(points[i]);
    }
    return out;
  }

  static void _simplifySegment(
    List<LatLng> points,
    int first,
    int last,
    double tolerance,
    List<bool> keep,
  ) {
    if (last <= first + 1) return;

    var maxDistance = 0.0;
    var index = first;

    for (var i = first + 1; i < last; i++) {
      final d = _perpendicularDistance(points[i], points[first], points[last]);
      if (d > maxDistance) {
        maxDistance = d;
        index = i;
      }
    }

    if (maxDistance <= tolerance) return;

    keep[index] = true;
    _simplifySegment(points, first, index, tolerance, keep);
    _simplifySegment(points, index, last, tolerance, keep);
  }

  /// Distance from [point] to the segment [start]–[end], in metres.
  ///
  /// Computed in a local metre-based frame rather than in degrees: a degree of
  /// longitude is 111 km at the equator and 71 km in the Punjab, so a
  /// tolerance in degrees means something different in every field.
  static double _perpendicularDistance(LatLng point, LatLng start, LatLng end) {
    final latRad = GeoUtils.degreesToRadians(start.latitude);
    const metresPerDegreeLat = 111320.0;
    final metresPerDegreeLng = metresPerDegreeLat * cos(latRad);

    final px = (point.longitude - start.longitude) * metresPerDegreeLng;
    final py = (point.latitude - start.latitude) * metresPerDegreeLat;
    final ex = (end.longitude - start.longitude) * metresPerDegreeLng;
    final ey = (end.latitude - start.latitude) * metresPerDegreeLat;

    final lengthSquared = ex * ex + ey * ey;
    if (lengthSquared == 0) return sqrt(px * px + py * py);

    // Projection parameter, clamped so a point beyond either end measures to
    // the endpoint rather than to the infinite line.
    final t = ((px * ex + py * ey) / lengthSquared).clamp(0.0, 1.0);
    final dx = px - t * ex;
    final dy = py - t * ey;

    return sqrt(dx * dx + dy * dy);
  }
}
