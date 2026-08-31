import '../entities/pest_risk_entity.dart';

/// Contract for pest risk data access.
abstract class PestRepository {
  /// Returns all pest risk zones for the given [fieldId].
  ///
  /// If [fieldId] is null, returns zones across all fields.
  Future<List<PestRiskZone>> getPestRiskZones({String? fieldId});

  /// Returns all pest alerts, optionally filtered by [fieldId].
  Future<List<PestAlert>> getPestAlerts({String? fieldId});

  /// Returns risk zones filtered by [riskLevel].
  Future<List<PestRiskZone>> getPestRiskZonesByLevel(RiskLevel riskLevel);

  /// Returns a single pest alert by [alertId].
  Future<PestAlert> getPestAlertById(String alertId);

  /// Marks an alert as read.
  Future<void> markAlertAsRead(String alertId);
}
