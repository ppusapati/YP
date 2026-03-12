import 'dart:typed_data';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logging/logging.dart';

import '../../domain/entities/diagnosis_entity.dart';
import '../../domain/repositories/diagnosis_repository.dart';
import '../datasources/diagnosis_local_datasource.dart';
import '../datasources/diagnosis_remote_datasource.dart';

/// Repository implementation that submits diagnoses via ConnectRPC,
/// caches results in Drift, and serves from cache when offline.
class DiagnosisRepositoryImpl implements DiagnosisRepository {
  DiagnosisRepositoryImpl({
    required DiagnosisRemoteDataSource remoteDataSource,
    required DiagnosisLocalDataSource localDataSource,
    required Connectivity connectivity,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _connectivity = connectivity;

  final DiagnosisRemoteDataSource _remoteDataSource;
  final DiagnosisLocalDataSource _localDataSource;
  final Connectivity _connectivity;
  final _log = Logger('DiagnosisRepository');

  Future<bool> get _isOnline async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  @override
  Future<Diagnosis> submitDiagnosis({
    required String fieldId,
    required String imagePath,
  }) async {
    final model = await _remoteDataSource.submitDiagnosis(
      fieldId: fieldId,
      imagePath: imagePath,
    );
    await _localDataSource.cacheDiagnosis(model);
    return model.toEntity();
  }

  @override
  Future<String> uploadImage(Uint8List imageBytes, String fileName) async {
    return _remoteDataSource.uploadImage(imageBytes, fileName);
  }

  @override
  Future<List<Diagnosis>> getDiagnosisHistory({String? fieldId}) async {
    if (await _isOnline) {
      try {
        final remote =
            await _remoteDataSource.getDiagnosisHistory(fieldId: fieldId);
        await _localDataSource.cacheDiagnoses(remote);
        return remote.map((m) => m.toEntity()).toList();
      } catch (e) {
        _log.warning('Remote diagnosis history fetch failed: $e');
      }
    }
    final cached =
        await _localDataSource.getDiagnosisHistory(fieldId: fieldId);
    return cached.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Diagnosis> getDiagnosisById(String diagnosisId) async {
    if (await _isOnline) {
      try {
        final remote =
            await _remoteDataSource.getDiagnosisById(diagnosisId);
        await _localDataSource.cacheDiagnosis(remote);
        return remote.toEntity();
      } catch (e) {
        _log.warning('Remote diagnosis fetch failed: $e');
      }
    }
    final cached = await _localDataSource.getDiagnosisById(diagnosisId);
    if (cached == null) {
      throw DiagnosisNotFoundException(
          'Diagnosis $diagnosisId not found in cache');
    }
    return cached.toEntity();
  }
}

/// Thrown when a diagnosis cannot be found.
class DiagnosisNotFoundException implements Exception {
  final String message;
  const DiagnosisNotFoundException(this.message);

  @override
  String toString() => 'DiagnosisNotFoundException: $message';
}
