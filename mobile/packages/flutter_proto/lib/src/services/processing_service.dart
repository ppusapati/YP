import 'package:http/http.dart' as http;

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
      'yieldpoint.satellite.processing.v1.SatelliteProcessingService';

  /// Submits a new processing job.
  Future<ProcessingJob> submitProcessingJob(ProcessingJob job) async {
    final bytes = await callUnary('SubmitProcessingJob', job);
    return ProcessingJob.fromBuffer(bytes);
  }

  /// Retrieves a processing job by ID.
  Future<ProcessingJob> getProcessingJob(String id) async {
    final request = ProcessingJob(id: id);
    final bytes = await callUnary('GetProcessingJob', request);
    return ProcessingJob.fromBuffer(bytes);
  }

  /// Lists processing jobs.
  Future<List<ProcessingJob>> listProcessingJobs({int pageSize = 20}) async {
    final request = ProcessingJob();
    final bytes = await callUnary('ListProcessingJobs', request);
    final job = ProcessingJob.fromBuffer(bytes);
    return [job];
  }

  /// Cancels a processing job by ID.
  Future<void> cancelProcessingJob(String id) async {
    final request = ProcessingJob(id: id);
    await callUnary('CancelProcessingJob', request);
  }

  /// Retrieves processing statistics.
  Future<ProcessingStats> getProcessingStats() async {
    final request = ProcessingStats();
    final bytes = await callUnary('GetProcessingStats', request);
    return ProcessingStats.fromBuffer(bytes);
  }
}
