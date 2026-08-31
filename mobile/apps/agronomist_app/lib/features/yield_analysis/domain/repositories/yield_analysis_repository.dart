import '../entities/yield_prediction_entity.dart';

abstract class YieldAnalysisRepository {
  Future<List<YieldPredictionEntity>> getYieldForecast(String fieldId);
  Future<List<YieldPredictionEntity>> getYieldHistory(String fieldId);
}
