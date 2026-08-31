import '../entities/alert_entity.dart';
import '../repositories/alert_repository.dart';

class GetAlertsUseCase {
  const GetAlertsUseCase(this._repository);

  final AlertRepository _repository;

  Future<List<Alert>> call({String? farmId, AlertSeverity? severity}) async {
    return _repository.getAlerts(farmId: farmId, severity: severity);
  }
}
