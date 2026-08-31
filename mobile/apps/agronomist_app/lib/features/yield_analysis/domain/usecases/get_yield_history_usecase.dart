import '../entities/yield_prediction_entity.dart';
import '../repositories/yield_analysis_repository.dart';

class GetYieldHistoryUseCase {
  final YieldAnalysisRepository _repository;
  const GetYieldHistoryUseCase(this._repository);
  Future<List<YieldPredictionEntity>> call(String fieldId) => _repository.getYieldHistory(fieldId);
}
