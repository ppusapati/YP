import 'package:latlong2/latlong.dart';

import '../../domain/entities/crop_issue_entity.dart';
import '../../domain/entities/gps_track_entity.dart';
import 'crop_issue_model.dart';

class GPSTrackModel extends GPSTrack {
  const GPSTrackModel({
    required super.id,
    required super.fieldId,
    super.path,
    required super.startTime,
    super.endTime,
    super.distance,
    super.issues,
  });

  factory GPSTrackModel.fromJson(Map<String, dynamic> json) {
    final pathList = json['path'] as List<dynamic>? ?? [];
    final issuesList = json['issues'] as List<dynamic>? ?? [];

    return GPSTrackModel(
      id: json['id'] as String,
      fieldId: json['field_id'] as String,
      path: pathList.map((p) {
        final point = p as Map<String, dynamic>;
        return LatLng(
          (point['lat'] as num).toDouble(),
          (point['lng'] as num).toDouble(),
        );
      }).toList(),
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'] as String)
          : null,
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      issues: issuesList
          .map((e) => CropIssueModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'field_id': fieldId,
      'path': path
          .map((p) => {'lat': p.latitude, 'lng': p.longitude})
          .toList(),
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'distance': distance,
      'issues': issues
          .map((i) => CropIssueModel.fromEntity(i).toJson())
          .toList(),
    };
  }

  factory GPSTrackModel.fromEntity(GPSTrack track) {
    return GPSTrackModel(
      id: track.id,
      fieldId: track.fieldId,
      path: track.path,
      startTime: track.startTime,
      endTime: track.endTime,
      distance: track.distance,
      issues: track.issues,
    );
  }
}
