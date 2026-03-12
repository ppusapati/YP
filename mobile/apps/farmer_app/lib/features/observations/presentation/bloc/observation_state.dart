import 'package:equatable/equatable.dart';

import '../../domain/entities/observation_entity.dart';

/// States for the observation BLoC.
sealed class ObservationState extends Equatable {
  const ObservationState();

  @override
  List<Object?> get props => [];
}

class ObservationInitial extends ObservationState {
  const ObservationInitial();
}

class ObservationLoading extends ObservationState {
  const ObservationLoading();
}

class ObservationsLoaded extends ObservationState {
  const ObservationsLoaded({required this.observations});

  final List<FieldObservation> observations;

  @override
  List<Object?> get props => [observations];
}

class ObservationCreated extends ObservationState {
  const ObservationCreated(this.observation);

  final FieldObservation observation;

  @override
  List<Object?> get props => [observation];
}

/// Tracks photos added before the observation is submitted.
class ObservationPhotosUpdated extends ObservationState {
  const ObservationPhotosUpdated(this.photos);

  final List<String> photos;

  @override
  List<Object?> get props => [photos];
}

class ObservationError extends ObservationState {
  const ObservationError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
