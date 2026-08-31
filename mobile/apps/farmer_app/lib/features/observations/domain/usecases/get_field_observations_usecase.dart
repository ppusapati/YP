import '../entities/observation_entity.dart';
import '../repositories/observation_repository.dart';

/// Retrieves observations for a specific field.
class GetFieldObservationsUseCase {
  const GetFieldObservationsUseCase(this._repository);

  final ObservationRepository _repository;

  Future<List<FieldObservation>> call(String fieldId) {
    return _repository.getFieldObservations(fieldId);
  }
}
