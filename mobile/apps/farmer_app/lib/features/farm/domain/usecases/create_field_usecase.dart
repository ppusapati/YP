import '../entities/field_entity.dart';
import '../repositories/farm_repository.dart';

/// Use case for creating a field within a farm.
class CreateFieldUseCase {
  final FarmRepository _repository;

  const CreateFieldUseCase(this._repository);

  /// Creates a new field and returns the persisted entity.
  Future<FieldEntity> call(FieldEntity field) {
    return _repository.createField(field);
  }
}
