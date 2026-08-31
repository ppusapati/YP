import '../entities/pest_risk_entity.dart';
import '../repositories/pest_repository.dart';

/// Retrieves pest alerts for display and notification purposes.
class GetPestAlertsUseCase {
  const GetPestAlertsUseCase(this._repository);

  final PestRepository _repository;

  /// Returns all alerts, optionally filtered by [fieldId].
  Future<List<PestAlert>> call({String? fieldId}) {
    return _repository.getPestAlerts(fieldId: fieldId);
  }

  /// Retrieves a single alert by its [alertId].
  Future<PestAlert> byId(String alertId) {
    return _repository.getPestAlertById(alertId);
  }

  /// Marks the given [alertId] as read.
  Future<void> markAsRead(String alertId) {
    return _repository.markAlertAsRead(alertId);
  }
}
