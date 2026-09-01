import '../generated/traceability.pb.dart';
import 'base_service.dart';

/// ConnectRPC service client for produce traceability.
///
/// Provides operations for produce records, supply chain events,
/// certifications, and farm-to-market tracking.
class TraceabilityServiceClient extends BaseService {
  TraceabilityServiceClient({
    required super.baseUrl,
    super.httpClient,
    super.interceptors,
  });

  @override
  String get serviceName => 'agriculture.traceability.v1.TraceabilityService';

  /// Retrieves a produce record by ID.
  Future<GetRecordResponse> getRecord(String recordId) async {
    final request = GetRecordRequest(id: recordId);
    final bytes = await callUnary('GetRecord', request);
    return GetRecordResponse.fromBuffer(bytes);
  }

  /// Lists produce records.
  Future<ListRecordsResponse> listRecords({
    required String farmId,
    int pageSize = 20,
    String pageToken = '',
  }) async {
    final request = ListRecordsRequest(
      farmId: farmId,
      pageSize: pageSize,
      pageToken: pageToken,
    );
    final bytes = await callUnary('ListRecords', request);
    return ListRecordsResponse.fromBuffer(bytes);
  }

  /// Creates a new produce record.
  Future<CreateRecordResponse> createRecord(
      CreateRecordRequest request) async {
    final bytes = await callUnary('CreateRecord', request);
    return CreateRecordResponse.fromBuffer(bytes);
  }

  /// Adds a supply chain event to a record.
  Future<AddSupplyChainEventResponse> addSupplyChainEvent(
      AddSupplyChainEventRequest request) async {
    final bytes = await callUnary('AddSupplyChainEvent', request);
    return AddSupplyChainEventResponse.fromBuffer(bytes);
  }

  /// Creates a certification for a record.
  Future<CreateCertificationResponse> createCertification(
      CreateCertificationRequest request) async {
    final bytes = await callUnary('CreateCertification', request);
    return CreateCertificationResponse.fromBuffer(bytes);
  }

  /// Retrieves the supply chain for a record.
  Future<GetSupplyChainResponse> getSupplyChain(String recordId) async {
    final request = GetSupplyChainRequest(recordId: recordId);
    final bytes = await callUnary('GetSupplyChain', request);
    return GetSupplyChainResponse.fromBuffer(bytes);
  }
}
