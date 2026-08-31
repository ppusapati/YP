import '../entities/prescription_entity.dart';
import '../repositories/prescription_repository.dart';

/// Use case for generating a new prescription.
class GeneratePrescriptionUseCase {
  final PrescriptionRepository _repository;

  const GeneratePrescriptionUseCase(this._repository);

  Future<PrescriptionBundle> call({
    required String fieldId,
    required String cropType,
    required double targetYield,
    List<List<double>>? soilData,
  }) {
    return _repository.generatePrescription(
      fieldId: fieldId,
      cropType: cropType,
      targetYield: targetYield,
      soilData: soilData,
    );
  }
}
