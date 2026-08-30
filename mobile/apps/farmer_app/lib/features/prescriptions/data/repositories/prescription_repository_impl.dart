import 'package:logging/logging.dart';

import '../../domain/entities/prescription_entity.dart';
import '../../domain/repositories/prescription_repository.dart';
import '../datasources/prescription_remote_datasource.dart';

/// Repository implementation for prescriptions.
class PrescriptionRepositoryImpl implements PrescriptionRepository {
  final PrescriptionRemoteDataSource _remoteDataSource;
  final _log = Logger('PrescriptionRepository');

  PrescriptionRepositoryImpl({
    required PrescriptionRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<List<PrescriptionBundle>> getPrescriptions({
    PrescriptionType? prescriptionType,
  }) async {
    try {
      final models = await _remoteDataSource.getPrescriptions(
        prescriptionType: prescriptionType?.name,
      );
      return models.map((m) => m.toEntity()).toList();
    } catch (e) {
      _log.warning('Failed to fetch prescriptions: $e');
      rethrow;
    }
  }

  @override
  Future<PrescriptionBundle> getPrescriptionById(String id) async {
    try {
      final model = await _remoteDataSource.getPrescriptionById(id);
      return model.toEntity();
    } catch (e) {
      _log.warning('Failed to fetch prescription $id: $e');
      rethrow;
    }
  }

  @override
  Future<PrescriptionBundle> generatePrescription({
    required String fieldId,
    required String cropType,
    required double targetYield,
    List<List<double>>? soilData,
  }) async {
    try {
      final model = await _remoteDataSource.generatePrescription(
        fieldId: fieldId,
        cropType: cropType,
        targetYield: targetYield,
        soilData: soilData,
      );
      return model.toEntity();
    } catch (e) {
      _log.warning('Failed to generate prescription: $e');
      rethrow;
    }
  }
}
