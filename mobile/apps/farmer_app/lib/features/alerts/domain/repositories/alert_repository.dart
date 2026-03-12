import '../entities/alert_entity.dart';

abstract class AlertRepository {
  Future<List<Alert>> getAlerts({String? farmId, AlertSeverity? severity});
  Future<Alert> getAlertById(String alertId);
  Future<void> markAlertRead(String alertId);
  Future<void> markAllAlertsRead({String? farmId});
  Future<int> getUnreadCount({String? farmId});
  Future<List<Alert>> refreshAlerts({String? farmId});
}
