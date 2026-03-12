import '../entities/pest_risk_entity.dart';
import '../repositories/pest_repository.dart';

/// Retrieves pest risk zones, optionally filtered by field or risk level.
class GetPestRiskZonesUseCase {
  const GetPestRiskZonesUseCase(this._repository);

  final PestRepository _repository;

  /// Returns all zones for [fieldId], or all zones when null.
  Future<List<PestRiskZone>> call({String? fieldId}) {
    return _repository.getPestRiskZones(fieldId: fieldId);
  }

  /// Returns zones matching the given [riskLevel].
  Future<List<PestRiskZone>> byLevel(RiskLevel riskLevel) {
    return _repository.getPestRiskZonesByLevel(riskLevel);
  }
}
