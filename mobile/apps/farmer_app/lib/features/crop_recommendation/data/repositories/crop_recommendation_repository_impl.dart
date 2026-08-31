import '../../domain/entities/crop_recommendation_entity.dart';
import '../../domain/repositories/crop_recommendation_repository.dart';
import '../datasources/crop_recommendation_remote_datasource.dart';

class CropRecommendationRepositoryImpl
    implements CropRecommendationRepository {
  CropRecommendationRepositoryImpl({
    required CropRecommendationRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final CropRecommendationRemoteDataSource _remoteDataSource;

  @override
  Future<List<CropRecommendation>> getRecommendations({
    required String fieldId,
  }) async {
    return _remoteDataSource.getRecommendations(fieldId: fieldId);
  }
}
