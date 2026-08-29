import '../entities/soil_analysis_entity.dart';
import '../repositories/soil_analysis_repository.dart';

class CreateSoilAnalysisUseCase {
  final SoilAnalysisRepository _repository;

  const CreateSoilAnalysisUseCase(this._repository);

  Future<SoilAnalysisEntity> call(SoilAnalysisEntity analysis) {
    return _repository.createSoilAnalysis(analysis);
  }
}
