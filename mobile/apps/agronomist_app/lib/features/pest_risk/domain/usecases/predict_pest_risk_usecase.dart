import '../entities/pest_risk_entity.dart';
import '../repositories/pest_risk_repository.dart';

class PredictPestRiskUseCase {
  final PestRiskRepository _repository;
  const PredictPestRiskUseCase(this._repository);

  Future<List<PestRiskEntity>> call(String fieldId) {
    return _repository.getPestRisks(fieldId);
  }
}
