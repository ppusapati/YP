import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/crop_issue_entity.dart';

sealed class GPSTrackingEvent extends Equatable {
  const GPSTrackingEvent();

  @override
  List<Object?> get props => [];
}

final class StartTracking extends GPSTrackingEvent {
  const StartTracking(this.fieldId);
  final String fieldId;

  @override
  List<Object?> get props => [fieldId];
}

final class StopTracking extends GPSTrackingEvent {
  const StopTracking();
}

final class AddWaypoint extends GPSTrackingEvent {
  const AddWaypoint(this.position);
  final LatLng position;

  @override
  List<Object?> get props => [position];
}

final class MarkIssue extends GPSTrackingEvent {
  const MarkIssue({
    required this.location,
    required this.type,
    required this.description,
    required this.severity,
    this.photos = const [],
  });

  final LatLng location;
  final CropIssueType type;
  final String description;
  final CropIssueSeverity severity;
  final List<String> photos;

  @override
  List<Object?> get props => [location, type, description, severity, photos];
}

final class PauseTracking extends GPSTrackingEvent {
  const PauseTracking();
}

final class ResumeTracking extends GPSTrackingEvent {
  const ResumeTracking();
}
