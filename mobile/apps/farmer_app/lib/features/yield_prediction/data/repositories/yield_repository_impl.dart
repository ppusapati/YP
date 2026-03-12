import '../../domain/entities/yield_prediction_entity.dart';
import '../../domain/repositories/yield_repository.dart';
import '../datasources/yield_local_datasource.dart';
import '../datasources/yield_remote_datasource.dart';
import '../models/yield_prediction_model.dart';

class YieldRepositoryImpl implements YieldRepository {
  YieldRepositoryImpl({
    required YieldRemoteDataSource remoteDataSource,
    required YieldLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  final YieldRemoteDataSource _remoteDataSource;
  final YieldLocalDataSource _localDataSource;

  @override
  Future<List<YieldPrediction>> getYieldPredictions({
    String? fieldId,
    String? cropType,
  }) async {
    try {
      final predictions = await _remoteDataSource.getPredictions(
        fieldId: fieldId,
        cropType: cropType,
      );
      await _localDataSource.cachePredictions(predictions);
      return predictions;
    } catch (_) {
      final cached = await _localDataSource.getCachedPredictions();
      var filtered = cached.toList();
      if (fieldId != null) {
        filtered = filtered.where((p) => p.fieldId == fieldId).toList();
      }
      if (cropType != null) {
        filtered = filtered.where((p) => p.cropType == cropType).toList();
      }
      return filtered;
    }
  }

  @override
  Future<YieldPrediction> getPredictionById(String predictionId) async {
    try {
      return await _remoteDataSource.getPredictionById(predictionId);
    } catch (_) {
      final cached = await _localDataSource.getCachedPredictions();
      return cached.firstWhere(
        (p) => p.id == predictionId,
        orElse: () => throw Exception('Prediction not found in cache'),
      );
    }
  }

  @override
  Future<List<YieldPrediction>> getYieldHistory(
    String fieldId, {
    String? cropType,
  }) async {
    try {
      final history = await _remoteDataSource.getHistory(
        fieldId,
        cropType: cropType,
      );
      await _localDataSource.cacheHistory(
        fieldId,
        history
            .map((h) => YieldPredictionModel.fromEntity(h))
            .toList(),
      );
      return history;
    } catch (_) {
      return _localDataSource.getCachedHistory(fieldId);
    }
  }
}
