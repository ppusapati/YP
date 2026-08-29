import '../entities/diagnosis_entity.dart';
import '../repositories/diagnosis_repository.dart';

class SubmitDiagnosisUseCase {
  final DiagnosisRepository _repository;
  const SubmitDiagnosisUseCase(this._repository);

  Future<DiagnosisEntity> call(DiagnosisEntity diagnosis) {
    return _repository.submitDiagnosis(diagnosis);
  }
}
