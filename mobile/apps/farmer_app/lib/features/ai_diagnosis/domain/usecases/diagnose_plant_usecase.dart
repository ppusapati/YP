import '../entities/diagnosis_entity.dart';
import '../repositories/diagnosis_repository.dart';

/// Use case for uploading a plant image and getting an AI diagnosis.
class DiagnosePlantUseCase {
  final DiagnosisRepository _repository;

  const DiagnosePlantUseCase(this._repository);

  /// Submits an image for AI diagnosis and returns the result.
  Future<Diagnosis> call({
    required String fieldId,
    required String imagePath,
  }) {
    return _repository.submitDiagnosis(
      fieldId: fieldId,
      imagePath: imagePath,
    );
  }
}
