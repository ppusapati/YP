import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

import 'crop_issue_entity.dart';

/// Represents a GPS walking track through a field.
class GPSTrack extends Equatable {
  final String id;
  final String fieldId;
  final List<LatLng> path;
  final DateTime startTime;
  final DateTime? endTime;
  final double distance;
  final List<CropIssue> issues;

  const GPSTrack({
    required this.id,
    required this.fieldId,
    this.path = const [],
    required this.startTime,
    this.endTime,
    this.distance = 0.0,
    this.issues = const [],
  });

  /// Track duration, or elapsed time since start if still active.
  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  /// Whether the track is still active (no end time).
  bool get isActive => endTime == null;

  /// Average speed in km/h.
  double get averageSpeedKmh {
    final durationHours = duration.inSeconds / 3600.0;
    if (durationHours == 0) return 0;
    return (distance / 1000.0) / durationHours;
  }

  GPSTrack copyWith({
    String? id,
    String? fieldId,
    List<LatLng>? path,
    DateTime? startTime,
    DateTime? Function()? endTime,
    double? distance,
    List<CropIssue>? issues,
  }) {
    return GPSTrack(
      id: id ?? this.id,
      fieldId: fieldId ?? this.fieldId,
      path: path ?? this.path,
      startTime: startTime ?? this.startTime,
      endTime: endTime != null ? endTime() : this.endTime,
      distance: distance ?? this.distance,
      issues: issues ?? this.issues,
    );
  }

  @override
  List<Object?> get props => [
        id,
        fieldId,
        path,
        startTime,
        endTime,
        distance,
        issues,
      ];

  @override
  String toString() => 'GPSTrack(id: $id, fieldId: $fieldId, '
      'points: ${path.length}, distance: ${distance.toStringAsFixed(1)}m)';
}
