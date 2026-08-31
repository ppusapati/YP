import '../entities/diagnosis_entity.dart';
import '../repositories/diagnosis_repository.dart';

class GetDiagnosesUseCase {
  final DiagnosisRepository _repository;
  const GetDiagnosesUseCase(this._repository);

  Future<List<DiagnosisEntity>> call({String? fieldId}) {
    return _repository.getDiagnoses(fieldId: fieldId);
  }
}
