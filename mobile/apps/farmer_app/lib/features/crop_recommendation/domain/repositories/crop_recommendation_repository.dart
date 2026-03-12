import '../entities/crop_recommendation_entity.dart';

abstract class CropRecommendationRepository {
  Future<List<CropRecommendation>> getRecommendations({
    required String fieldId,
  });
}
