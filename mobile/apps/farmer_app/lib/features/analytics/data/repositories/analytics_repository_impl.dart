import 'package:logging/logging.dart';

import '../../domain/entities/field_analytics_entity.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../datasources/analytics_remote_datasource.dart';

/// Repository implementation for historical analytics.
class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsRemoteDataSource _remoteDataSource;
  final _log = Logger('AnalyticsRepository');

  AnalyticsRepositoryImpl({
    required AnalyticsRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<List<FieldAnalytics>> getFieldAnalyticsList(
      {String? farmId}) async {
    try {
      final models =
          await _remoteDataSource.getFieldAnalyticsList(farmId: farmId);
      return models.map((m) => m.toEntity()).toList();
    } catch (e) {
      _log.warning('Failed to fetch field analytics list: $e');
      rethrow;
    }
  }

  @override
  Future<FieldAnalytics> getFieldAnalytics(String fieldId) async {
    try {
      final model = await _remoteDataSource.getFieldAnalytics(fieldId);
      return model.toEntity();
    } catch (e) {
      _log.warning('Failed to fetch field analytics for $fieldId: $e');
      rethrow;
    }
  }

  @override
  Future<List<SeasonComparison>> getSeasonComparisons(
      String fieldId) async {
    try {
      final models =
          await _remoteDataSource.getSeasonComparisons(fieldId);
      return models.map((m) => m.toEntity()).toList();
    } catch (e) {
      _log.warning('Failed to fetch season comparisons for $fieldId: $e');
      rethrow;
    }
  }

  @override
  Future<RotationScore> getRotationAnalysis(String fieldId) async {
    try {
      final model = await _remoteDataSource.getRotationAnalysis(fieldId);
      return model.toEntity();
    } catch (e) {
      _log.warning('Failed to fetch rotation analysis for $fieldId: $e');
      rethrow;
    }
  }
}
