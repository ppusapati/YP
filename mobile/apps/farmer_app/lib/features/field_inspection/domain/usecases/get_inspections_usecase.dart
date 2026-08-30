import '../entities/inspection_entity.dart';
import '../repositories/field_inspection_repository.dart';

/// Use case for retrieving inspections.
class GetInspectionsUseCase {
  final FieldInspectionRepository _repository;

  const GetInspectionsUseCase(this._repository);

  Future<List<InspectionEntity>> call({String? farmId}) {
    return _repository.getInspections(farmId: farmId);
  }
}
