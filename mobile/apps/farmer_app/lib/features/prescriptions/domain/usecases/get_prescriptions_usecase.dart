import '../entities/prescription_entity.dart';
import '../repositories/prescription_repository.dart';

/// Use case for retrieving prescriptions.
class GetPrescriptionsUseCase {
  final PrescriptionRepository _repository;

  const GetPrescriptionsUseCase(this._repository);

  /// Retrieves all prescription bundles, optionally filtered by type.
  Future<List<PrescriptionBundle>> call({
    PrescriptionType? prescriptionType,
  }) {
    return _repository.getPrescriptions(
        prescriptionType: prescriptionType);
  }

  /// Retrieves a single prescription bundle by ID.
  Future<PrescriptionBundle> getById(String id) {
    return _repository.getPrescriptionById(id);
  }
}
