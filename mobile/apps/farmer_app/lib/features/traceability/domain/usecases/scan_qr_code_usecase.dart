import '../entities/produce_record_entity.dart';
import '../repositories/traceability_repository.dart';

/// Scans a QR code and retrieves the associated produce record.
class ScanQrCodeUseCase {
  const ScanQrCodeUseCase(this._repository);

  final TraceabilityRepository _repository;

  Future<ProduceRecord> call(String qrData) {
    return _repository.scanQrCode(qrData);
  }
}
