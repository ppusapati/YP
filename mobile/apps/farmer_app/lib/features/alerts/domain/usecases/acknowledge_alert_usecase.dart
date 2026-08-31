import '../entities/alert_entity.dart';
import '../repositories/alert_repository.dart';

class AcknowledgeAlertUseCase {
  const AcknowledgeAlertUseCase(this._repository);

  final AlertRepository _repository;

  Future<Alert> call(String alertId) async {
    return _repository.acknowledgeAlert(alertId);
  }
}
