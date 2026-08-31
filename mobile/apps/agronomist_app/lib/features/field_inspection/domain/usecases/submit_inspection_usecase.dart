import '../entities/inspection_entity.dart';
import '../repositories/field_inspection_repository.dart';

/// Use case for submitting a draft inspection.
class SubmitInspectionUseCase {
  final FieldInspectionRepository _repository;

  const SubmitInspectionUseCase(this._repository);

  Future<InspectionEntity> call(String inspectionId) {
    return _repository.submitInspection(inspectionId);
  }
}
