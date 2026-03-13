import '../entities/satellite_data_entity.dart';
import '../entities/stress_alert_entity.dart';

/// Abstract repository interface for satellite monitoring operations.
abstract class SatelliteRepository {
  /// Retrieves satellite tiles for a specific field.
  Future<List<SatelliteDataEntity>> getTilesForField(String fieldId);

  /// Retrieves stress alerts for a farm.
  Future<List<StressAlertEntity>> getStressAlerts(String farmId);

  /// Retrieves field analytics summary for a specific farm and field.
  Future<FieldAnalyticsSummary> getFieldAnalyticsSummary(
      String farmId, String fieldId);

  /// Runs a temporal analysis on a field.
  Future<TemporalAnalysis> runTemporalAnalysis(
      String farmId, String fieldId, String type);
}
