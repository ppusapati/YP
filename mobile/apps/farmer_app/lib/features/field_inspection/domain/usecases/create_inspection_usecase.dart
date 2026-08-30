import '../entities/inspection_entity.dart';
import '../repositories/field_inspection_repository.dart';

/// Use case for creating a new field inspection.
class CreateInspectionUseCase {
  final FieldInspectionRepository _repository;

  const CreateInspectionUseCase(this._repository);

  Future<InspectionEntity> call(InspectionEntity inspection) {
    return _repository.createInspection(inspection);
  }
}
