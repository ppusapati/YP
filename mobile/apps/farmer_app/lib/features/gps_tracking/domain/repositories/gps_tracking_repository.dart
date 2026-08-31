import 'package:latlong2/latlong.dart';

import '../entities/crop_issue_entity.dart';
import '../entities/gps_track_entity.dart';

abstract class GPSTrackingRepository {
  Future<GPSTrack> startTracking(String fieldId);
  Future<GPSTrack> stopTracking(String trackId);
  Future<GPSTrack> addWaypoint(String trackId, LatLng point);
  Future<CropIssue> markIssue({
    required String trackId,
    required LatLng location,
    required CropIssueType type,
    required String description,
    required CropIssueSeverity severity,
    List<String> photos,
  });
  Future<List<GPSTrack>> getTracks({String? fieldId});
  Future<GPSTrack> getTrackById(String trackId);
  Future<void> deleteTrack(String trackId);
}
