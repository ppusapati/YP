import '../entities/soil_analysis_entity.dart';
import '../repositories/soil_repository.dart';

class GetSoilHistoryUseCase {
  const GetSoilHistoryUseCase(this._repository);

  final SoilRepository _repository;

  Future<List<SoilAnalysis>> call(
    String fieldId, {
    DateTime? from,
    DateTime? to,
  }) async {
    return _repository.getSoilHistory(fieldId, from: from, to: to);
  }
}
