import '../../domain/entities/yield_prediction_entity.dart';
import '../../domain/repositories/yield_analysis_repository.dart';
import '../datasources/yield_analysis_remote_datasource.dart';

class YieldAnalysisRepositoryImpl implements YieldAnalysisRepository {
  final YieldAnalysisRemoteDataSource _remoteDataSource;
  YieldAnalysisRepositoryImpl({required YieldAnalysisRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<List<YieldPredictionEntity>> getYieldForecast(String fieldId) async {
    final remote = await _remoteDataSource.getYieldForecast(fieldId);
    return remote.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<YieldPredictionEntity>> getYieldHistory(String fieldId) async {
    final remote = await _remoteDataSource.getYieldHistory(fieldId);
    return remote.map((m) => m.toEntity()).toList();
  }
}
