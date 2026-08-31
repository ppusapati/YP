import '../entities/advisory_entity.dart';
import '../repositories/crop_advisory_repository.dart';

/// Use case for creating a crop advisory.
class CreateAdvisoryUseCase {
  final CropAdvisoryRepository _repository;

  const CreateAdvisoryUseCase(this._repository);

  Future<AdvisoryEntity> call(AdvisoryEntity advisory) {
    return _repository.createAdvisory(advisory);
  }
}
