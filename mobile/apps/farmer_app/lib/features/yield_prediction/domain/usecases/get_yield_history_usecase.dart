import '../entities/yield_prediction_entity.dart';
import '../repositories/yield_repository.dart';

class GetYieldHistoryUseCase {
  const GetYieldHistoryUseCase(this._repository);

  final YieldRepository _repository;

  Future<List<YieldPrediction>> call(
    String fieldId, {
    String? cropType,
  }) async {
    return _repository.getYieldHistory(fieldId, cropType: cropType);
  }
}
