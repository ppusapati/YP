import '../entities/satellite_tile_entity.dart';
import '../repositories/satellite_repository.dart';

/// Use case for retrieving satellite tiles for a field within a date range.
class GetSatelliteTilesUseCase {
  final SatelliteRepository _repository;

  const GetSatelliteTilesUseCase(this._repository);

  Future<List<SatelliteTileEntity>> call({
    required String fieldId,
    required DateTime from,
    required DateTime to,
    SatelliteIndexType indexType = SatelliteIndexType.ndvi,
  }) {
    return _repository.getSatelliteTiles(
      fieldId: fieldId,
      from: from,
      to: to,
      indexType: indexType,
    );
  }
}
