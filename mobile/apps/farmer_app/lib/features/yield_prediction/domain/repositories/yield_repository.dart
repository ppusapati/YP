import '../entities/yield_prediction_entity.dart';

abstract class YieldRepository {
  Future<List<YieldPrediction>> getYieldPredictions({
    String? fieldId,
    String? cropType,
  });
  Future<YieldPrediction> getPredictionById(String predictionId);
  Future<List<YieldPrediction>> getYieldHistory(
    String fieldId, {
    String? cropType,
  });
}
