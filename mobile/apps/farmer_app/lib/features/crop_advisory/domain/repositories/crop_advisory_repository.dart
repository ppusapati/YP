import '../entities/advisory_entity.dart';

/// Abstract repository interface for crop advisory operations.
abstract class CropAdvisoryRepository {
  Future<List<AdvisoryEntity>> getAdvisories({String? farmId});
  Future<AdvisoryEntity> getAdvisoryById(String id);
  Future<AdvisoryEntity> createAdvisory(AdvisoryEntity advisory);
}
