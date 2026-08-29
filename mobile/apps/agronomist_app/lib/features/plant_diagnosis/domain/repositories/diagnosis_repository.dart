import '../entities/diagnosis_entity.dart';

abstract class DiagnosisRepository {
  Future<DiagnosisEntity> submitDiagnosis(DiagnosisEntity diagnosis);
  Future<List<DiagnosisEntity>> getDiagnoses({String? fieldId});
  Future<DiagnosisEntity> getDiagnosisById(String id);
}
