import '../entities/yield_prediction_entity.dart';
import '../repositories/yield_analysis_repository.dart';

class GetYieldForecastUseCase {
  final YieldAnalysisRepository _repository;
  const GetYieldForecastUseCase(this._repository);
  Future<List<YieldPredictionEntity>> call(String fieldId) => _repository.getYieldForecast(fieldId);
}
