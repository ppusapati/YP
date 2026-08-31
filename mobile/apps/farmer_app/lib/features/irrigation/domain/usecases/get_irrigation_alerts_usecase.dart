import '../entities/irrigation_alert_entity.dart';
import '../repositories/irrigation_repository.dart';

class GetIrrigationAlertsUseCase {
  const GetIrrigationAlertsUseCase(this._repository);

  final IrrigationRepository _repository;

  Future<List<IrrigationAlert>> call({String? zoneId}) async {
    return _repository.getAlerts(zoneId: zoneId);
  }
}
