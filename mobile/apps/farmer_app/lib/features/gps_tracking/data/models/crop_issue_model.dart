import 'package:latlong2/latlong.dart';

import '../../domain/entities/crop_issue_entity.dart';

class CropIssueModel extends CropIssue {
  const CropIssueModel({
    required super.id,
    required super.trackId,
    required super.location,
    required super.type,
    super.description,
    super.photos,
    super.severity,
    required super.timestamp,
  });

  factory CropIssueModel.fromJson(Map<String, dynamic> json) {
    final loc = json['location'] as Map<String, dynamic>;
    return CropIssueModel(
      id: json['id'] as String,
      trackId: json['track_id'] as String,
      location: LatLng(
        (loc['lat'] as num).toDouble(),
        (loc['lng'] as num).toDouble(),
      ),
      type: CropIssueType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CropIssueType.other,
      ),
      description: json['description'] as String? ?? '',
      photos: (json['photos'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      severity: CropIssueSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => CropIssueSeverity.moderate,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'track_id': trackId,
      'location': {'lat': location.latitude, 'lng': location.longitude},
      'type': type.name,
      'description': description,
      'photos': photos,
      'severity': severity.name,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory CropIssueModel.fromEntity(CropIssue issue) {
    return CropIssueModel(
      id: issue.id,
      trackId: issue.trackId,
      location: issue.location,
      type: issue.type,
      description: issue.description,
      photos: issue.photos,
      severity: issue.severity,
      timestamp: issue.timestamp,
    );
  }
}
