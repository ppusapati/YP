import '../../domain/entities/pest_risk_entity.dart';
import '../../domain/repositories/pest_risk_repository.dart';
import '../datasources/pest_risk_remote_datasource.dart';

class PestRiskRepositoryImpl implements PestRiskRepository {
  final PestRiskRemoteDataSource _remoteDataSource;

  PestRiskRepositoryImpl({required PestRiskRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<List<PestRiskEntity>> getPestRisks(String fieldId) async {
    final remote = await _remoteDataSource.getPestRisks(fieldId);
    return remote.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<PestRiskEntity>> getPestAlerts() async {
    final remote = await _remoteDataSource.getPestAlerts();
    return remote.map((m) => m.toEntity()).toList();
  }
}
