import '../entities/prescription_entity.dart';

/// Abstract repository interface for prescription operations.
abstract class PrescriptionRepository {
  /// Retrieves all prescription bundles, optionally filtered by type.
  Future<List<PrescriptionBundle>> getPrescriptions({
    PrescriptionType? prescriptionType,
  });

  /// Retrieves a single prescription bundle by ID.
  Future<PrescriptionBundle> getPrescriptionById(String id);

  /// Generates a new prescription bundle for a field.
  Future<PrescriptionBundle> generatePrescription({
    required String fieldId,
    required String cropType,
    required double targetYield,
    List<List<double>>? soilData,
  });
}
