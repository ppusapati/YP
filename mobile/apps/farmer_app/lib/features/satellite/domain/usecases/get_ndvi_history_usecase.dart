import '../entities/satellite_entity.dart';
import '../repositories/satellite_repository.dart';

/// Use case for retrieving NDVI history data for a field.
class GetNdviHistoryUseCase {
  final SatelliteRepository _repository;

  const GetNdviHistoryUseCase(this._repository);

  Future<List<NdviDataPoint>> call({
    required String fieldId,
    required DateTime from,
    required DateTime to,
  }) {
    return _repository.getNdviHistory(
      fieldId: fieldId,
      from: from,
      to: to,
    );
  }
}
