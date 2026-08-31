import '../entities/crop_health_entity.dart';
import '../repositories/satellite_repository.dart';

/// Use case for retrieving crop health time-series data for a field.
class GetCropHealthUseCase {
  final SatelliteRepository _repository;

  const GetCropHealthUseCase(this._repository);

  Future<CropHealthEntity> call({required String fieldId}) {
    return _repository.getCropHealth(fieldId: fieldId);
  }
}
