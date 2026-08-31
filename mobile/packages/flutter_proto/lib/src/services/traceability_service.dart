import 'package:http/http.dart' as http;

import '../generated/traceability.pb.dart';
import 'base_service.dart';

/// ConnectRPC service client for produce traceability.
///
/// Provides CRUD operations for produce records, enabling
/// farm-to-market tracking and certification management.
class TraceabilityServiceClient extends BaseService {
  TraceabilityServiceClient({
    required super.baseUrl,
    super.httpClient,
    super.interceptors,
  });

  @override
  String get serviceName => 'yieldpoint.traceability.v1.TraceabilityService';

  /// Retrieves a produce record by ID.
  Future<ProduceRecord> getRecord(String recordId) async {
    final request = ProduceRecord(id: recordId);
    final bytes = await callUnary('GetRecord', request);
    return ProduceRecord.fromBuffer(bytes);
  }

  /// Lists produce records for a farm.
  Future<List<ProduceRecord>> listRecords({
    required String farmId,
    String? cropVariety,
    int pageSize = 20,
  }) async {
    final request = ProduceRecord(
      farmId: farmId,
      cropVariety: cropVariety,
    );
    final bytes = await callUnary('ListRecords', request);
    final record = ProduceRecord.fromBuffer(bytes);
    return [record];
  }

  /// Creates a new produce record.
  Future<ProduceRecord> createRecord(ProduceRecord record) async {
    final bytes = await callUnary('CreateRecord', record);
    return ProduceRecord.fromBuffer(bytes);
  }

  /// Updates an existing produce record.
  Future<ProduceRecord> updateRecord(ProduceRecord record) async {
    final bytes = await callUnary('UpdateRecord', record);
    return ProduceRecord.fromBuffer(bytes);
  }

  /// Deletes a produce record by ID.
  Future<void> deleteRecord(String recordId) async {
    final request = ProduceRecord(id: recordId);
    await callUnary('DeleteRecord', request);
  }

  /// Adds a certification to a produce record.
  Future<ProduceRecord> addCertification({
    required String recordId,
    required String certification,
  }) async {
    final request = ProduceRecord(
      id: recordId,
      certifications: [certification],
    );
    final bytes = await callUnary('AddCertification', request);
    return ProduceRecord.fromBuffer(bytes);
  }

  /// Adds a treatment to a produce record.
  Future<ProduceRecord> addTreatment({
    required String recordId,
    required String treatment,
  }) async {
    final request = ProduceRecord(
      id: recordId,
      treatments: [treatment],
    );
    final bytes = await callUnary('AddTreatment', request);
    return ProduceRecord.fromBuffer(bytes);
  }
}
