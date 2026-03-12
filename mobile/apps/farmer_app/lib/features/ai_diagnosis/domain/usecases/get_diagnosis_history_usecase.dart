import '../entities/diagnosis_entity.dart';
import '../repositories/diagnosis_repository.dart';

/// Use case for retrieving past diagnosis history.
class GetDiagnosisHistoryUseCase {
  final DiagnosisRepository _repository;

  const GetDiagnosisHistoryUseCase(this._repository);

  /// Returns diagnosis history, optionally filtered by [fieldId].
  Future<List<Diagnosis>> call({String? fieldId}) {
    return _repository.getDiagnosisHistory(fieldId: fieldId);
  }
}
