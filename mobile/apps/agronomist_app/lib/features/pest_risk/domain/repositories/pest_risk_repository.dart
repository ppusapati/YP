import '../entities/pest_risk_entity.dart';

abstract class PestRiskRepository {
  Future<List<PestRiskEntity>> getPestRisks(String fieldId);
  Future<List<PestRiskEntity>> getPestAlerts();
}
