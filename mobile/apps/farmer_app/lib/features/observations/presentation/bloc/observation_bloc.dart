import 'package:bloc/bloc.dart';
import 'package:logging/logging.dart';

import '../../domain/usecases/create_observation_usecase.dart';
import '../../domain/usecases/get_observations_usecase.dart';
import 'observation_event.dart';
import 'observation_state.dart';

/// BLoC managing field observation lifecycle.
class ObservationBloc extends Bloc<ObservationEvent, ObservationState> {
  ObservationBloc({
    required GetObservationsUseCase getObservations,
    required CreateObservationUseCase createObservation,
  })  : _getObservations = getObservations,
        _createObservation = createObservation,
        super(const ObservationInitial()) {
    on<LoadObservations>(_onLoad);
    on<CreateObservation>(_onCreate);
    on<AddPhoto>(_onAddPhoto);
    on<RemovePhoto>(_onRemovePhoto);
    on<DeleteObservation>(_onDelete);
  }

  final GetObservationsUseCase _getObservations;
  final CreateObservationUseCase _createObservation;
  static final _log = Logger('ObservationBloc');

  /// Pending photo paths for the observation being composed.
  final List<String> _pendingPhotos = [];

  LoadObservations? _lastLoadEvent;

  Future<void> _onLoad(
    LoadObservations event,
    Emitter<ObservationState> emit,
  ) async {
    _lastLoadEvent = event;
    emit(const ObservationLoading());
    try {
      final observations = await _getObservations(fieldId: event.fieldId);
      emit(ObservationsLoaded(observations: observations));
    } catch (e, stack) {
      _log.severe('Failed to load observations', e, stack);
      emit(const ObservationError(
          'Unable to load observations. Please try again.'));
    }
  }

  Future<void> _onCreate(
    CreateObservation event,
    Emitter<ObservationState> emit,
  ) async {
    emit(const ObservationLoading());
    try {
      final created = await _createObservation(event.observation);
      _pendingPhotos.clear();
      emit(ObservationCreated(created));
      // Reload list.
      if (_lastLoadEvent != null) add(_lastLoadEvent!);
    } catch (e, stack) {
      _log.severe('Failed to create observation', e, stack);
      emit(const ObservationError(
          'Unable to save observation. Please try again.'));
    }
  }

  void _onAddPhoto(AddPhoto event, Emitter<ObservationState> emit) {
    _pendingPhotos.add(event.photoPath);
    emit(ObservationPhotosUpdated(List.unmodifiable(_pendingPhotos)));
  }

  void _onRemovePhoto(RemovePhoto event, Emitter<ObservationState> emit) {
    if (event.index >= 0 && event.index < _pendingPhotos.length) {
      _pendingPhotos.removeAt(event.index);
      emit(ObservationPhotosUpdated(List.unmodifiable(_pendingPhotos)));
    }
  }

  Future<void> _onDelete(
    DeleteObservation event,
    Emitter<ObservationState> emit,
  ) async {
    try {
      final current = state;
      if (current is ObservationsLoaded) {
        final updated = current.observations
            .where((o) => o.id != event.observationId)
            .toList();
        emit(ObservationsLoaded(observations: updated));
      }
      if (_lastLoadEvent != null) add(_lastLoadEvent!);
    } catch (e, stack) {
      _log.severe('Failed to delete observation', e, stack);
      emit(const ObservationError(
          'Unable to delete observation. Please try again.'));
    }
  }
}
