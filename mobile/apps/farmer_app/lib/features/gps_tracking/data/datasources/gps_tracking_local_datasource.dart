import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/crop_issue_model.dart';
import '../models/gps_track_model.dart';

abstract class GPSTrackingLocalDataSource {
  Future<List<GPSTrackModel>> getTracks();
  Future<GPSTrackModel?> getTrackById(String trackId);
  Future<void> saveTrack(GPSTrackModel track);
  Future<void> deleteTrack(String trackId);
  Future<void> saveIssue(CropIssueModel issue);
  Future<GPSTrackModel?> getActiveTrack();
}

class GPSTrackingLocalDataSourceImpl implements GPSTrackingLocalDataSource {
  const GPSTrackingLocalDataSourceImpl(this._prefs);

  final SharedPreferences _prefs;

  static const _tracksKey = 'gps_tracks';

  @override
  Future<List<GPSTrackModel>> getTracks() async {
    final jsonString = _prefs.getString(_tracksKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
    return jsonList
        .map((e) => GPSTrackModel.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  @override
  Future<GPSTrackModel?> getTrackById(String trackId) async {
    final tracks = await getTracks();
    return tracks.where((t) => t.id == trackId).firstOrNull;
  }

  @override
  Future<void> saveTrack(GPSTrackModel track) async {
    final tracks = await getTracks();
    final index = tracks.indexWhere((t) => t.id == track.id);
    if (index >= 0) {
      tracks[index] = track;
    } else {
      tracks.add(track);
    }
    await _persistTracks(tracks);
  }

  @override
  Future<void> deleteTrack(String trackId) async {
    final tracks = await getTracks();
    tracks.removeWhere((t) => t.id == trackId);
    await _persistTracks(tracks);
  }

  @override
  Future<void> saveIssue(CropIssueModel issue) async {
    final tracks = await getTracks();
    final trackIndex = tracks.indexWhere((t) => t.id == issue.trackId);
    if (trackIndex < 0) return;

    final track = tracks[trackIndex];
    final updatedIssues = [...track.issues, issue];
    tracks[trackIndex] = GPSTrackModel.fromEntity(
      track.copyWith(issues: updatedIssues),
    );
    await _persistTracks(tracks);
  }

  @override
  Future<GPSTrackModel?> getActiveTrack() async {
    final tracks = await getTracks();
    return tracks.where((t) => t.isActive).firstOrNull;
  }

  Future<void> _persistTracks(List<GPSTrackModel> tracks) async {
    final jsonList = tracks.map((t) => t.toJson()).toList();
    await _prefs.setString(_tracksKey, jsonEncode(jsonList));
  }
}
