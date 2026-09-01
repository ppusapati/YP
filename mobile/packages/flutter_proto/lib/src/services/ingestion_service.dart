import '../generated/ingestion.pb.dart';
import 'base_service.dart';

/// ConnectRPC service client for satellite imagery ingestion.
///
/// Provides operations for requesting, managing, and monitoring
/// satellite imagery ingestion tasks.
class IngestionServiceClient extends BaseService {
  IngestionServiceClient({
    required super.baseUrl,
    super.httpClient,
    super.interceptors,
  });

  @override
  String get serviceName =>
      'agriculture.satellite.ingestion.v1.SatelliteIngestionService';

  /// Requests a new satellite imagery ingestion.
  Future<RequestIngestionResponse> requestIngestion(
      RequestIngestionRequest request) async {
    final bytes = await callUnary('RequestIngestion', request);
    return RequestIngestionResponse.fromBuffer(bytes);
  }

  /// Retrieves an ingestion task by ID.
  Future<GetIngestionTaskResponse> getIngestionTask(String id) async {
    final request = GetIngestionTaskRequest(id: id);
    final bytes = await callUnary('GetIngestionTask', request);
    return GetIngestionTaskResponse.fromBuffer(bytes);
  }

  /// Lists ingestion tasks.
  Future<ListIngestionTasksResponse> listIngestionTasks({
    int pageSize = 20,
    String pageToken = '',
  }) async {
    final request = ListIngestionTasksRequest(
      pageSize: pageSize,
      pageToken: pageToken,
    );
    final bytes = await callUnary('ListIngestionTasks', request);
    return ListIngestionTasksResponse.fromBuffer(bytes);
  }

  /// Cancels an ingestion task by ID.
  Future<void> cancelIngestion(String id) async {
    final request = CancelIngestionRequest(id: id);
    await callUnary('CancelIngestion', request);
  }

  /// Retries a failed ingestion task.
  Future<RetryIngestionResponse> retryIngestion(String id) async {
    final request = RetryIngestionRequest(id: id);
    final bytes = await callUnary('RetryIngestion', request);
    return RetryIngestionResponse.fromBuffer(bytes);
  }

  /// Retrieves ingestion statistics.
  Future<GetIngestionStatsResponse> getIngestionStats({
    String? farmId,
  }) async {
    final request = GetIngestionStatsRequest(farmId: farmId);
    final bytes = await callUnary('GetIngestionStats', request);
    return GetIngestionStatsResponse.fromBuffer(bytes);
  }
}
