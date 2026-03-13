import 'package:http/http.dart' as http;

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
      'yieldpoint.satellite.ingestion.v1.SatelliteIngestionService';

  /// Requests a new satellite imagery ingestion.
  Future<IngestionTask> requestIngestion(IngestionTask task) async {
    final bytes = await callUnary('RequestIngestion', task);
    return IngestionTask.fromBuffer(bytes);
  }

  /// Retrieves an ingestion task by ID.
  Future<IngestionTask> getIngestionTask(String id) async {
    final request = IngestionTask(id: id);
    final bytes = await callUnary('GetIngestionTask', request);
    return IngestionTask.fromBuffer(bytes);
  }

  /// Lists ingestion tasks.
  Future<List<IngestionTask>> listIngestionTasks({int pageSize = 20}) async {
    final request = IngestionTask();
    final bytes = await callUnary('ListIngestionTasks', request);
    final task = IngestionTask.fromBuffer(bytes);
    return [task];
  }

  /// Cancels an ingestion task by ID.
  Future<void> cancelIngestion(String id) async {
    final request = IngestionTask(id: id);
    await callUnary('CancelIngestion', request);
  }

  /// Retries a failed ingestion task.
  Future<IngestionTask> retryIngestion(String id) async {
    final request = IngestionTask(id: id);
    final bytes = await callUnary('RetryIngestion', request);
    return IngestionTask.fromBuffer(bytes);
  }

  /// Retrieves ingestion statistics.
  Future<IngestionStats> getIngestionStats() async {
    final request = IngestionStats();
    final bytes = await callUnary('GetIngestionStats', request);
    return IngestionStats.fromBuffer(bytes);
  }
}
