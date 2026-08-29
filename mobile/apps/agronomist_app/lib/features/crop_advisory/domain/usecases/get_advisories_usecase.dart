import '../entities/advisory_entity.dart';
import '../repositories/crop_advisory_repository.dart';

/// Use case for retrieving crop advisories.
class GetAdvisoriesUseCase {
  final CropAdvisoryRepository _repository;

  const GetAdvisoriesUseCase(this._repository);

  Future<List<AdvisoryEntity>> call({String? farmId}) {
    return _repository.getAdvisories(farmId: farmId);
  }
}
