import '../entities/soil_analysis_entity.dart';
import '../repositories/soil_analysis_repository.dart';

class GetSoilAnalysesUseCase {
  final SoilAnalysisRepository _repository;

  const GetSoilAnalysesUseCase(this._repository);

  Future<List<SoilAnalysisEntity>> call(String fieldId) {
    return _repository.getSoilAnalyses(fieldId);
  }
}
