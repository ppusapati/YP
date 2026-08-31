import '../entities/observation_entity.dart';
import '../repositories/observation_repository.dart';

/// Retrieves all field observations across fields.
class GetObservationsUseCase {
  const GetObservationsUseCase(this._repository);

  final ObservationRepository _repository;

  Future<List<FieldObservation>> call({String? fieldId}) {
    return _repository.getObservations(fieldId: fieldId);
  }
}
