import 'package:flutter_network/flutter_network.dart';
import 'package:logging/logging.dart';

import '../../domain/entities/observation_entity.dart';
import '../../domain/repositories/observation_repository.dart';
import '../datasources/observation_local_datasource.dart';
import '../datasources/observation_remote_datasource.dart';
import '../models/observation_model.dart';

/// Concrete [ObservationRepository] with remote-first, local-fallback strategy.
class ObservationRepositoryImpl implements ObservationRepository {
  ObservationRepositoryImpl({
    required ObservationRemoteDataSource remoteDataSource,
    required ObservationLocalDataSource localDataSource,
  })  : _remote = remoteDataSource,
        _local = localDataSource;

  final ObservationRemoteDataSource _remote;
  final ObservationLocalDataSource _local;
  static final _log = Logger('ObservationRepositoryImpl');

  @override
  Future<List<FieldObservation>> getObservations({String? fieldId}) async {
    try {
      final observations =
          await _remote.fetchObservations(fieldId: fieldId);
      await _local.cacheObservations(observations);
      return observations;
    } on ConnectException catch (e) {
      _log.warning('Remote fetch failed, using cache: $e');
      final cached = await _local.getCachedObservations();
      if (fieldId != null) {
        return cached.where((o) => o.fieldId == fieldId).toList();
      }
      return cached;
    }
  }

  @override
  Future<List<FieldObservation>> getFieldObservations(String fieldId) async {
    return getObservations(fieldId: fieldId);
  }

  @override
  Future<FieldObservation> getObservationById(String observationId) async {
    return _remote.fetchObservationById(observationId);
  }

  @override
  Future<FieldObservation> createObservation(
    FieldObservation observation,
  ) async {
    final model = ObservationModel.fromEntity(observation);
    final created = await _remote.createObservation(model);
    await _local.cacheObservation(created);
    return created;
  }

  @override
  Future<void> deleteObservation(String observationId) async {
    await _remote.deleteObservation(observationId);
    await _local.removeObservation(observationId);
  }

  @override
  Future<String> uploadPhoto(String localPath) async {
    return _remote.uploadPhoto(localPath);
  }
}
