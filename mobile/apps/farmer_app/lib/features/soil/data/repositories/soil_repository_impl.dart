import '../../domain/entities/soil_analysis_entity.dart';
import '../../domain/repositories/soil_repository.dart';
import '../datasources/soil_local_datasource.dart';
import '../datasources/soil_remote_datasource.dart';
import '../models/soil_analysis_model.dart';

class SoilRepositoryImpl implements SoilRepository {
  SoilRepositoryImpl({
    required SoilRemoteDataSource remoteDataSource,
    required SoilLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  final SoilRemoteDataSource _remoteDataSource;
  final SoilLocalDataSource _localDataSource;

  @override
  Future<SoilAnalysis> getSoilAnalysis(String fieldId) async {
    try {
      final analysis = await _remoteDataSource.getSoilAnalysis(fieldId);
      await _localDataSource.cacheAnalysis(analysis);
      return analysis;
    } catch (_) {
      final cached = await _localDataSource.getCachedAnalysis(fieldId);
      if (cached != null) return cached;
      rethrow;
    }
  }

  @override
  Future<List<SoilAnalysis>> getSoilHistory(
    String fieldId, {
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      final history = await _remoteDataSource.getSoilHistory(
        fieldId,
        from: from,
        to: to,
      );
      await _localDataSource.cacheHistory(
        fieldId,
        history.map((h) => SoilAnalysisModel.fromEntity(h)).toList(),
      );
      return history;
    } catch (_) {
      return _localDataSource.getCachedHistory(fieldId);
    }
  }

  @override
  Future<List<SoilAnalysis>> getAllFieldAnalyses() async {
    return _remoteDataSource.getAllFieldAnalyses();
  }
}
