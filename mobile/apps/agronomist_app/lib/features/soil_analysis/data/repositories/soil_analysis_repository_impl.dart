import 'package:flutter_network/flutter_network.dart';
import 'package:logging/logging.dart';

import '../../domain/entities/soil_analysis_entity.dart';
import '../../domain/repositories/soil_analysis_repository.dart';
import '../datasources/soil_analysis_local_datasource.dart';
import '../datasources/soil_analysis_remote_datasource.dart';
import '../models/soil_analysis_model.dart';

class SoilAnalysisRepositoryImpl implements SoilAnalysisRepository {
  final SoilAnalysisRemoteDataSource _remoteDataSource;
  final SoilAnalysisLocalDataSource _localDataSource;
  final ConnectivityService _connectivityService;
  final _log = Logger('SoilAnalysisRepository');

  SoilAnalysisRepositoryImpl({
    required SoilAnalysisRemoteDataSource remoteDataSource,
    required SoilAnalysisLocalDataSource localDataSource,
    required ConnectivityService connectivityService,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _connectivityService = connectivityService;

  bool get _isOnline =>
      _connectivityService.currentStatus == ConnectivityStatus.online;

  @override
  Future<List<SoilAnalysisEntity>> getSoilAnalyses(String fieldId) async {
    if (_isOnline) {
      try {
        final remote = await _remoteDataSource.getSoilAnalyses(fieldId);
        await _localDataSource.cacheSoilAnalyses(fieldId, remote);
        return remote.map((m) => m.toEntity()).toList();
      } catch (e) {
        _log.warning('Remote fetch failed, falling back to cache: $e');
      }
    }
    final cached = await _localDataSource.getSoilAnalyses(fieldId);
    return cached.map((m) => m.toEntity()).toList();
  }

  @override
  Future<SoilAnalysisEntity> createSoilAnalysis(
      SoilAnalysisEntity analysis) async {
    final model = SoilAnalysisModel.fromEntity(analysis);
    final created = await _remoteDataSource.createSoilAnalysis(model);
    return created.toEntity();
  }
}
