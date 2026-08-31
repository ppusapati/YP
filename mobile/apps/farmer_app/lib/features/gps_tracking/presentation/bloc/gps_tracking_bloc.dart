import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:logging/logging.dart';

import '../../domain/usecases/mark_issue_usecase.dart';
import '../../domain/usecases/start_tracking_usecase.dart';
import '../../domain/usecases/stop_tracking_usecase.dart';
import 'gps_tracking_event.dart';
import 'gps_tracking_state.dart';

class GPSTrackingBloc extends Bloc<GPSTrackingEvent, GPSTrackingState> {
  GPSTrackingBloc({
    required StartTrackingUseCase startTracking,
    required StopTrackingUseCase stopTracking,
    required MarkIssueUseCase markIssue,
  })  : _startTracking = startTracking,
        _stopTracking = stopTracking,
        _markIssue = markIssue,
        super(const TrackingInitial()) {
    on<StartTracking>(_onStartTracking);
    on<StopTracking>(_onStopTracking);
    on<AddWaypoint>(_onAddWaypoint);
    on<MarkIssue>(_onMarkIssue);
    on<PauseTracking>(_onPauseTracking);
    on<ResumeTracking>(_onResumeTracking);
  }

  final StartTrackingUseCase _startTracking;
  final StopTrackingUseCase _stopTracking;
  final MarkIssueUseCase _markIssue;

  StreamSubscription<Position>? _positionSubscription;
  Timer? _durationTimer;
  DateTime? _trackingStartTime;

  static final _log = Logger('GPSTrackingBloc');

  Future<void> _onStartTracking(
    StartTracking event,
    Emitter<GPSTrackingState> emit,
  ) async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.denied ||
            requested == LocationPermission.deniedForever) {
          emit(const TrackingError('Location permission denied'));
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      final currentLatLng = LatLng(position.latitude, position.longitude);

      final track = await _startTracking(event.fieldId);
      _trackingStartTime = DateTime.now();

      emit(TrackingActive(
        track: track,
        currentPosition: currentLatLng,
      ));

      _startLocationStream();
      _startDurationTimer();
    } catch (e, s) {
      _log.severe('Failed to start tracking', e, s);
      emit(TrackingError(e.toString()));
    }
  }

  Future<void> _onStopTracking(
    StopTracking event,
    Emitter<GPSTrackingState> emit,
  ) async {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _durationTimer?.cancel();
    _durationTimer = null;

    final currentState = state;
    String? trackId;
    if (currentState is TrackingActive) {
      trackId = currentState.track.id;
    } else if (currentState is TrackingPaused) {
      trackId = currentState.track.id;
    }

    if (trackId == null) return;

    try {
      final summary = await _stopTracking(trackId);
      emit(TrackingStopped(summary: summary));
    } catch (e, s) {
      _log.severe('Failed to stop tracking', e, s);
      emit(TrackingError(e.toString()));
    }
  }

  Future<void> _onAddWaypoint(
    AddWaypoint event,
    Emitter<GPSTrackingState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TrackingActive) return;

    emit(currentState.copyWith(
      track: currentState.track.copyWith(
        path: [...currentState.track.path, event.position],
      ),
      currentPosition: event.position,
    ));
  }

  Future<void> _onMarkIssue(
    MarkIssue event,
    Emitter<GPSTrackingState> emit,
  ) async {
    final currentState = state;
    String? trackId;
    if (currentState is TrackingActive) {
      trackId = currentState.track.id;
    } else if (currentState is TrackingPaused) {
      trackId = currentState.track.id;
    }

    if (trackId == null) return;

    try {
      final issue = await _markIssue(
        trackId: trackId,
        location: event.location,
        type: event.type,
        description: event.description,
        severity: event.severity,
        photos: event.photos,
      );

      if (currentState is TrackingActive) {
        emit(currentState.copyWith(
          track: currentState.track.copyWith(
            issues: [...currentState.track.issues, issue],
          ),
        ));
      }
    } catch (e, s) {
      _log.severe('Failed to mark issue', e, s);
    }
  }

  void _onPauseTracking(
    PauseTracking event,
    Emitter<GPSTrackingState> emit,
  ) {
    final currentState = state;
    if (currentState is! TrackingActive) return;

    _positionSubscription?.pause();
    _durationTimer?.cancel();

    emit(TrackingPaused(
      track: currentState.track,
      lastPosition: currentState.currentPosition,
      elapsedDuration: currentState.elapsedDuration,
    ));
  }

  void _onResumeTracking(
    ResumeTracking event,
    Emitter<GPSTrackingState> emit,
  ) {
    final currentState = state;
    if (currentState is! TrackingPaused) return;

    emit(TrackingActive(
      track: currentState.track,
      currentPosition: currentState.lastPosition,
      elapsedDuration: currentState.elapsedDuration,
    ));

    _positionSubscription?.resume();
    _startDurationTimer();
  }

  void _startLocationStream() {
    _positionSubscription?.cancel();

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (position) {
        final latLng = LatLng(position.latitude, position.longitude);
        add(AddWaypoint(latLng));
      },
      onError: (Object error) {
        _log.warning('Location stream error: $error');
      },
    );
  }

  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final currentState = state;
      if (currentState is TrackingActive && _trackingStartTime != null) {
        // We emit duration updates by re-emitting current state
        // The UI reads elapsed from track.duration
      }
    });
  }

  @override
  Future<void> close() {
    _positionSubscription?.cancel();
    _durationTimer?.cancel();
    return super.close();
  }
}
