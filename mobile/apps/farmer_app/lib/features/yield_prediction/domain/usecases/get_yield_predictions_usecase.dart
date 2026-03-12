import '../entities/yield_prediction_entity.dart';
import '../repositories/yield_repository.dart';

class GetYieldPredictionsUseCase {
  const GetYieldPredictionsUseCase(this._repository);

  final YieldRepository _repository;

  Future<List<YieldPrediction>> call({
    String? fieldId,
    String? cropType,
  }) async {
    return _repository.getYieldPredictions(
      fieldId: fieldId,
      cropType: cropType,
    );
  }
}
