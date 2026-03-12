import 'dart:typed_data';

import '../entities/diagnosis_entity.dart';

/// Abstract repository interface for AI plant diagnosis operations.
abstract class DiagnosisRepository {
  /// Uploads an image and submits it for AI diagnosis.
  Future<Diagnosis> submitDiagnosis({
    required String fieldId,
    required String imagePath,
  });

  /// Uploads raw image bytes for diagnosis.
  Future<String> uploadImage(Uint8List imageBytes, String fileName);

  /// Retrieves past diagnosis history, optionally filtered by field.
  Future<List<Diagnosis>> getDiagnosisHistory({String? fieldId});

  /// Retrieves a single diagnosis by ID.
  Future<Diagnosis> getDiagnosisById(String diagnosisId);
}
