import '../generated/processing.pb.dart';
import 'base_service.dart';

/// ConnectRPC service client for satellite imagery processing.
///
/// Provides operations for submitting, managing, and monitoring
/// satellite imagery processing jobs.
class ProcessingServiceClient extends BaseService {
  ProcessingServiceClient({
    required super.baseUrl,
    super.httpClient,
    super.interceptors,
  });

  @override
  String get serviceName =>
      'agriculture.satellite.processing.v1.SatelliteProcessingService';

  /// Submits a new processing job.
  Future<SubmitProcessingJobResponse> submitProcessingJob(
      SubmitProcessingJobRequest request) async {
    final bytes = await callUnary('SubmitProcessingJob', request);
    return SubmitProcessingJobResponse.fromBuffer(bytes);
  }

  /// Retrieves a processing job by ID.
  Future<GetProcessingJobResponse> getProcessingJob(String id) async {
    final request = GetProcessingJobRequest(id: id);
    final bytes = await callUnary('GetProcessingJob', request);
    return GetProcessingJobResponse.fromBuffer(bytes);
  }

  /// Lists processing jobs.
  Future<ListProcessingJobsResponse> listProcessingJobs({
    int pageSize = 20,
    String pageToken = '',
  }) async {
    final request = ListProcessingJobsRequest(
      pageSize: pageSize,
      pageToken: pageToken,
    );
    final bytes = await callUnary('ListProcessingJobs', request);
    return ListProcessingJobsResponse.fromBuffer(bytes);
  }

  /// Cancels a processing job by ID.
  Future<void> cancelProcessingJob(String id) async {
    final request = CancelProcessingJobRequest(id: id);
    await callUnary('CancelProcessingJob', request);
  }

  /// Retrieves processing statistics.
  Future<GetProcessingStatsResponse> getProcessingStats({
    String? farmId,
  }) async {
    final request = GetProcessingStatsRequest(farmId: farmId);
    final bytes = await callUnary('GetProcessingStats', request);
    return GetProcessingStatsResponse.fromBuffer(bytes);
  }
}
