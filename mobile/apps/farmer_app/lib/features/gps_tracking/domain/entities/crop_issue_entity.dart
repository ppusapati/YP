import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/gps_track_entity.dart';

/// The type of crop issue observed during field walking.
enum CropIssueType {
  pest,
  disease,
  weed,
  nutrientDeficiency,
  waterStress,
  mechanicalDamage,
  wildlife,
  other;

  String get displayName {
    switch (this) {
      case CropIssueType.pest:
        return 'Pest';
      case CropIssueType.disease:
        return 'Disease';
      case CropIssueType.weed:
        return 'Weed';
      case CropIssueType.nutrientDeficiency:
        return 'Nutrient Deficiency';
      case CropIssueType.waterStress:
        return 'Water Stress';
      case CropIssueType.mechanicalDamage:
        return 'Mechanical Damage';
      case CropIssueType.wildlife:
        return 'Wildlife Damage';
      case CropIssueType.other:
        return 'Other';
    }
  }
}

/// The severity of a crop issue.
enum CropIssueSeverity {
  low,
  moderate,
  high,
  critical;

  String get displayName {
    switch (this) {
      case CropIssueSeverity.low:
        return 'Low';
      case CropIssueSeverity.moderate:
        return 'Moderate';
      case CropIssueSeverity.high:
        return 'High';
      case CropIssueSeverity.critical:
        return 'Critical';
    }
  }
}

/// Represents a crop issue marked during GPS field tracking.
class CropIssue extends Equatable {
  final String id;
  final String trackId;
  final LatLng location;
  final CropIssueType type;
  final String description;
  final List<String> photos;
  final CropIssueSeverity severity;
  final DateTime timestamp;

  const CropIssue({
    required this.id,
    required this.trackId,
    required this.location,
    required this.type,
    this.description = '',
    this.photos = const [],
    this.severity = CropIssueSeverity.moderate,
    required this.timestamp,
  });

  CropIssue copyWith({
    String? id,
    String? trackId,
    LatLng? location,
    CropIssueType? type,
    String? description,
    List<String>? photos,
    CropIssueSeverity? severity,
    DateTime? timestamp,
  }) {
    return CropIssue(
      id: id ?? this.id,
      trackId: trackId ?? this.trackId,
      location: location ?? this.location,
      type: type ?? this.type,
      description: description ?? this.description,
      photos: photos ?? this.photos,
      severity: severity ?? this.severity,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  List<Object?> get props => [
        id,
        trackId,
        location,
        type,
        description,
        photos,
        severity,
        timestamp,
      ];

  @override
  String toString() => 'CropIssue(id: $id, type: ${type.displayName})';
}
