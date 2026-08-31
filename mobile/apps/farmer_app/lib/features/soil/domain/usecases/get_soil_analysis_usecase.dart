import '../entities/soil_analysis_entity.dart';
import '../repositories/soil_repository.dart';

class GetSoilAnalysisUseCase {
  const GetSoilAnalysisUseCase(this._repository);

  final SoilRepository _repository;

  Future<SoilAnalysis> call(String fieldId) async {
    return _repository.getSoilAnalysis(fieldId);
  }
}
