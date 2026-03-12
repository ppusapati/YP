import '../entities/crop_recommendation_entity.dart';
import '../repositories/crop_recommendation_repository.dart';

class GetRecommendationsUseCase {
  const GetRecommendationsUseCase(this._repository);

  final CropRecommendationRepository _repository;

  Future<List<CropRecommendation>> call({required String fieldId}) async {
    return _repository.getRecommendations(fieldId: fieldId);
  }
}
