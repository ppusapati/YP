import '../entities/satellite_data_entity.dart';
import '../repositories/satellite_repository.dart';

/// Use case for retrieving the analytics summary for a field.
class GetFieldSummaryUseCase {
  final SatelliteRepository _repository;

  const GetFieldSummaryUseCase(this._repository);

  /// Returns the analytics summary for the given [farmId] and [fieldId].
  Future<FieldAnalyticsSummary> call(String farmId, String fieldId) {
    return _repository.getFieldAnalyticsSummary(farmId, fieldId);
  }
}
