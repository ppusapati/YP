import '../entities/observation_entity.dart';

/// Contract for field observation data access.
abstract class ObservationRepository {
  /// Returns all observations, optionally filtered by [fieldId].
  Future<List<FieldObservation>> getObservations({String? fieldId});

  /// Returns observations for a specific [fieldId].
  Future<List<FieldObservation>> getFieldObservations(String fieldId);

  /// Returns a single observation by [observationId].
  Future<FieldObservation> getObservationById(String observationId);

  /// Creates a new observation and returns the created entity.
  Future<FieldObservation> createObservation(FieldObservation observation);

  /// Deletes an observation by [observationId].
  Future<void> deleteObservation(String observationId);

  /// Uploads a photo and returns the remote URL.
  Future<String> uploadPhoto(String localPath);
}
