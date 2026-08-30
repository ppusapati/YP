import '../entities/field_analytics_entity.dart';

/// Abstract repository interface for historical analytics operations.
abstract class AnalyticsRepository {
  /// Retrieves analytics for all fields, optionally filtered by farm.
  Future<List<FieldAnalytics>> getFieldAnalyticsList({String? farmId});

  /// Retrieves detailed analytics for a specific field.
  Future<FieldAnalytics> getFieldAnalytics(String fieldId);

  /// Retrieves season comparisons for a specific field.
  Future<List<SeasonComparison>> getSeasonComparisons(String fieldId);

  /// Retrieves rotation analysis for a specific field.
  Future<RotationScore> getRotationAnalysis(String fieldId);
}
