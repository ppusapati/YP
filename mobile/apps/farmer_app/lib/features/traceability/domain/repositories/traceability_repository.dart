import '../entities/produce_record_entity.dart';

/// Contract for traceability data access.
abstract class TraceabilityRepository {
  /// Decodes a QR code string and returns the associated produce record.
  Future<ProduceRecord> scanQrCode(String qrData);

  /// Returns a produce record by its [recordId].
  Future<ProduceRecord> getProduceRecord(String recordId);

  /// Returns the produce history for a farm, ordered by harvest date descending.
  Future<List<ProduceRecord>> getFarmHistory(String farmId);
}
