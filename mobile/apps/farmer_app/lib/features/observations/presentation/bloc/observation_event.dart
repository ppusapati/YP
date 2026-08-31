import 'package:equatable/equatable.dart';

import '../../domain/entities/observation_entity.dart';

/// Events for the observation BLoC.
sealed class ObservationEvent extends Equatable {
  const ObservationEvent();

  @override
  List<Object?> get props => [];
}

/// Load all observations, optionally for a specific [fieldId].
class LoadObservations extends ObservationEvent {
  const LoadObservations({this.fieldId});

  final String? fieldId;

  @override
  List<Object?> get props => [fieldId];
}

/// Create a new field observation.
class CreateObservation extends ObservationEvent {
  const CreateObservation(this.observation);

  final FieldObservation observation;

  @override
  List<Object?> get props => [observation];
}

/// Add a photo path to the pending observation.
class AddPhoto extends ObservationEvent {
  const AddPhoto(this.photoPath);

  final String photoPath;

  @override
  List<Object?> get props => [photoPath];
}

/// Remove a photo at [index] from the pending observation.
class RemovePhoto extends ObservationEvent {
  const RemovePhoto(this.index);

  final int index;

  @override
  List<Object?> get props => [index];
}

/// Delete an existing observation.
class DeleteObservation extends ObservationEvent {
  const DeleteObservation(this.observationId);

  final String observationId;

  @override
  List<Object?> get props => [observationId];
}
