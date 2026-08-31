import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/gps_track_entity.dart';

sealed class GPSTrackingState extends Equatable {
  const GPSTrackingState();

  @override
  List<Object?> get props => [];
}

final class TrackingInitial extends GPSTrackingState {
  const TrackingInitial();
}

final class TrackingActive extends GPSTrackingState {
  const TrackingActive({
    required this.track,
    required this.currentPosition,
    this.elapsedDuration = Duration.zero,
  });

  final GPSTrack track;
  final LatLng currentPosition;
  final Duration elapsedDuration;

  TrackingActive copyWith({
    GPSTrack? track,
    LatLng? currentPosition,
    Duration? elapsedDuration,
  }) {
    return TrackingActive(
      track: track ?? this.track,
      currentPosition: currentPosition ?? this.currentPosition,
      elapsedDuration: elapsedDuration ?? this.elapsedDuration,
    );
  }

  @override
  List<Object?> get props => [track, currentPosition, elapsedDuration];
}

final class TrackingPaused extends GPSTrackingState {
  const TrackingPaused({
    required this.track,
    required this.lastPosition,
    required this.elapsedDuration,
  });

  final GPSTrack track;
  final LatLng lastPosition;
  final Duration elapsedDuration;

  @override
  List<Object?> get props => [track, lastPosition, elapsedDuration];
}

final class TrackingStopped extends GPSTrackingState {
  const TrackingStopped({required this.summary});

  final GPSTrack summary;

  @override
  List<Object?> get props => [summary];
}

final class TrackingError extends GPSTrackingState {
  const TrackingError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
