import '../repositories/alert_repository.dart';

class MarkAlertReadUseCase {
  const MarkAlertReadUseCase(this._repository);

  final AlertRepository _repository;

  Future<void> call(String alertId) async {
    return _repository.markAlertRead(alertId);
  }

  Future<void> markAll({String? farmId}) async {
    return _repository.markAllAlertsRead(farmId: farmId);
  }
}
