import '../entities/satellite_data_entity.dart';
import '../repositories/satellite_repository.dart';

/// Use case for retrieving satellite tiles for a field.
class GetSatelliteTilesUseCase {
  final SatelliteRepository _repository;

  const GetSatelliteTilesUseCase(this._repository);

  /// Returns all satellite tiles for the given [fieldId].
  Future<List<SatelliteDataEntity>> call(String fieldId) {
    return _repository.getTilesForField(fieldId);
  }
}
