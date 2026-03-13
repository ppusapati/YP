import '../entities/stress_alert_entity.dart';
import '../repositories/satellite_repository.dart';

/// Use case for retrieving stress alerts for a farm.
class GetStressAlertsUseCase {
  final SatelliteRepository _repository;

  const GetStressAlertsUseCase(this._repository);

  /// Returns all stress alerts for the given [farmId].
  Future<List<StressAlertEntity>> call(String farmId) {
    return _repository.getStressAlerts(farmId);
  }
}
