import 'package:flutter_network/flutter_network.dart';
import 'package:logging/logging.dart';

import '../../domain/entities/diagnosis_entity.dart';
import '../../domain/repositories/diagnosis_repository.dart';
import '../datasources/diagnosis_local_datasource.dart';
import '../datasources/diagnosis_remote_datasource.dart';
import '../models/diagnosis_model.dart';

class DiagnosisRepositoryImpl implements DiagnosisRepository {
  final DiagnosisRemoteDataSource _remoteDataSource;
  final DiagnosisLocalDataSource _localDataSource;
  final ConnectivityService _connectivityService;
  final _log = Logger('DiagnosisRepository');

  DiagnosisRepositoryImpl({
    required DiagnosisRemoteDataSource remoteDataSource,
    required DiagnosisLocalDataSource localDataSource,
    required ConnectivityService connectivityService,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _connectivityService = connectivityService;

  bool get _isOnline =>
      _connectivityService.currentStatus == ConnectivityStatus.online;

  @override
  Future<DiagnosisEntity> submitDiagnosis(DiagnosisEntity diagnosis) async {
    final model = DiagnosisModel.fromEntity(diagnosis);
    final created = await _remoteDataSource.submitDiagnosis(model);
    await _localDataSource.cacheDiagnosis(created);
    return created.toEntity();
  }

  @override
  Future<List<DiagnosisEntity>> getDiagnoses({String? fieldId}) async {
    if (_isOnline) {
      try {
        final remote =
            await _remoteDataSource.getDiagnoses(fieldId: fieldId);
        await _localDataSource.cacheDiagnoses(remote);
        return remote.map((m) => m.toEntity()).toList();
      } catch (e) {
        _log.warning('Remote fetch failed: $e');
      }
    }
    final cached = await _localDataSource.getDiagnoses();
    var entities = cached.map((m) => m.toEntity()).toList();
    if (fieldId != null) {
      entities = entities.where((e) => e.fieldId == fieldId).toList();
    }
    return entities;
  }

  @override
  Future<DiagnosisEntity> getDiagnosisById(String id) async {
    if (_isOnline) {
      try {
        final remote = await _remoteDataSource.getDiagnosisById(id);
        await _localDataSource.cacheDiagnosis(remote);
        return remote.toEntity();
      } catch (e) {
        _log.warning('Remote fetch failed for diagnosis $id: $e');
      }
    }
    final cached = await _localDataSource.getDiagnoses();
    final match = cached.where((m) => m.id == id).firstOrNull;
    if (match == null) throw Exception('Diagnosis $id not found in cache');
    return match.toEntity();
  }
}
