import '../entities/field_analytics_entity.dart';
import '../repositories/analytics_repository.dart';

/// Use case for retrieving field analytics.
class GetFieldAnalyticsUseCase {
  final AnalyticsRepository _repository;

  const GetFieldAnalyticsUseCase(this._repository);

  /// Retrieves analytics list for all fields, optionally filtered by farm.
  Future<List<FieldAnalytics>> call({String? farmId}) {
    return _repository.getFieldAnalyticsList(farmId: farmId);
  }

  /// Retrieves detailed analytics for a single field.
  Future<FieldAnalytics> getFieldDetail(String fieldId) {
    return _repository.getFieldAnalytics(fieldId);
  }
}
