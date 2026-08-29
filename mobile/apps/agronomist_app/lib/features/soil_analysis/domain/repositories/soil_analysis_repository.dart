import '../entities/soil_analysis_entity.dart';

/// Abstract repository interface for soil analysis operations.
abstract class SoilAnalysisRepository {
  Future<List<SoilAnalysisEntity>> getSoilAnalyses(String fieldId);
  Future<SoilAnalysisEntity> createSoilAnalysis(SoilAnalysisEntity analysis);
}
