import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/crop_issue_entity.dart';
import '../../domain/entities/gps_track_entity.dart';
import '../../domain/repositories/gps_tracking_repository.dart';
import '../datasources/gps_tracking_local_datasource.dart';
import '../models/crop_issue_model.dart';
import '../models/gps_track_model.dart';

class GPSTrackingRepositoryImpl implements GPSTrackingRepository {
  GPSTrackingRepositoryImpl({
    required GPSTrackingLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  final GPSTrackingLocalDataSource _localDataSource;
  static const _uuid = Uuid();
  static const _distanceCalc = Distance();

  @override
  Future<GPSTrack> startTracking(String fieldId) async {
    final track = GPSTrackModel(
      id: _uuid.v4(),
      fieldId: fieldId,
      startTime: DateTime.now(),
    );
    await _localDataSource.saveTrack(track);
    return track;
  }

  @override
  Future<GPSTrack> stopTracking(String trackId) async {
    final track = await _localDataSource.getTrackById(trackId);
    if (track == null) {
      throw Exception('Track not found: $trackId');
    }

    final stopped = GPSTrackModel.fromEntity(
      track.copyWith(endTime: () => DateTime.now()),
    );
    await _localDataSource.saveTrack(stopped);
    return stopped;
  }

  @override
  Future<GPSTrack> addWaypoint(String trackId, LatLng point) async {
    final track = await _localDataSource.getTrackById(trackId);
    if (track == null) {
      throw Exception('Track not found: $trackId');
    }

    final newPath = [...track.path, point];
    var newDistance = track.distance;
    if (track.path.isNotEmpty) {
      newDistance += _distanceCalc.as(
        LengthUnit.Meter,
        track.path.last,
        point,
      );
    }

    final updated = GPSTrackModel.fromEntity(
      track.copyWith(path: newPath, distance: newDistance),
    );
    await _localDataSource.saveTrack(updated);
    return updated;
  }

  @override
  Future<CropIssue> markIssue({
    required String trackId,
    required LatLng location,
    required CropIssueType type,
    required String description,
    required CropIssueSeverity severity,
    List<String> photos = const [],
  }) async {
    final issue = CropIssueModel(
      id: _uuid.v4(),
      trackId: trackId,
      location: location,
      type: type,
      description: description,
      severity: severity,
      photos: photos,
      timestamp: DateTime.now(),
    );
    await _localDataSource.saveIssue(issue);
    return issue;
  }

  @override
  Future<List<GPSTrack>> getTracks({String? fieldId}) async {
    final tracks = await _localDataSource.getTracks();
    if (fieldId != null) {
      return tracks.where((t) => t.fieldId == fieldId).toList();
    }
    return tracks;
  }

  @override
  Future<GPSTrack> getTrackById(String trackId) async {
    final track = await _localDataSource.getTrackById(trackId);
    if (track == null) {
      throw Exception('Track not found: $trackId');
    }
    return track;
  }

  @override
  Future<void> deleteTrack(String trackId) async {
    await _localDataSource.deleteTrack(trackId);
  }
}
