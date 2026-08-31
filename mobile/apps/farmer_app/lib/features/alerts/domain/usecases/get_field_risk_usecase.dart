import '../entities/alert_entity.dart';
import '../repositories/alert_repository.dart';

class GetFieldRiskUseCase {
  const GetFieldRiskUseCase(this._repository);

  final AlertRepository _repository;

  Future<FieldRiskScore> call(String fieldId) async {
    return _repository.getFieldRisk(fieldId);
  }
}
