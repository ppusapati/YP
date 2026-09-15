import '../entities/satellite_entity.dart';
import '../repositories/satellite_repository.dart';

/// Use case for retrieving satellite tiles for a field within a date range.
class GetSatelliteTilesUseCase {
  final SatelliteRepository _repository;

  const GetSatelliteTilesUseCase(this._repository);

  Future<List<SatelliteTile>> call({
    required String fieldId,
    required DateTime from,
    required DateTime to,
    SatelliteLayerType? layerType,
  }) {
    return _repository.getSatelliteTiles(
      fieldId: fieldId,
      from: from,
      to: to,
      layerType: layerType,
    );
  }
}
