import '../entities/soil_analysis_entity.dart';

abstract class SoilRepository {
  Future<SoilAnalysis> getSoilAnalysis(String fieldId);
  Future<List<SoilAnalysis>> getSoilHistory(
    String fieldId, {
    DateTime? from,
    DateTime? to,
  });
  Future<List<SoilAnalysis>> getAllFieldAnalyses();
}
