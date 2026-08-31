import '../entities/pest_risk_entity.dart';
import '../repositories/pest_risk_repository.dart';

class GetPestAlertsUseCase {
  final PestRiskRepository _repository;
  const GetPestAlertsUseCase(this._repository);

  Future<List<PestRiskEntity>> call() {
    return _repository.getPestAlerts();
  }
}
