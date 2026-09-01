import '../generated/analytics.pb.dart';
import 'base_service.dart';

/// ConnectRPC service client for satellite analytics.
///
/// Provides operations for stress detection, temporal analysis,
/// and field analytics summaries.
class AnalyticsServiceClient extends BaseService {
  AnalyticsServiceClient({
    required super.baseUrl,
    super.httpClient,
    super.interceptors,
  });

  @override
  String get serviceName =>
      'agriculture.satellite.analytics.v1.SatelliteAnalyticsService';

  /// Detects stress in a field.
  Future<DetectStressResponse> detectStress(
      DetectStressRequest request) async {
    final bytes = await callUnary('DetectStress', request);
    return DetectStressResponse.fromBuffer(bytes);
  }

  /// Lists stress alerts for a farm.
  Future<ListStressAlertsResponse> listStressAlerts({
    required String farmId,
    int pageSize = 20,
    String pageToken = '',
  }) async {
    final request = ListStressAlertsRequest(
      farmId: farmId,
      pageSize: pageSize,
      pageToken: pageToken,
    );
    final bytes = await callUnary('ListStressAlerts', request);
    return ListStressAlertsResponse.fromBuffer(bytes);
  }

  /// Acknowledges a stress alert.
  Future<AcknowledgeAlertResponse> acknowledgeAlert(String id) async {
    final request = AcknowledgeAlertRequest(id: id);
    final bytes = await callUnary('AcknowledgeAlert', request);
    return AcknowledgeAlertResponse.fromBuffer(bytes);
  }

  /// Runs a temporal analysis over a time period.
  Future<RunTemporalAnalysisResponse> runTemporalAnalysis(
      RunTemporalAnalysisRequest request) async {
    final bytes = await callUnary('RunTemporalAnalysis', request);
    return RunTemporalAnalysisResponse.fromBuffer(bytes);
  }

  /// Retrieves analytics summary for a field.
  Future<GetFieldAnalyticsSummaryResponse> getFieldAnalyticsSummary(
      String farmId, String fieldId) async {
    final request = GetFieldAnalyticsSummaryRequest(
      farmId: farmId,
      fieldId: fieldId,
    );
    final bytes = await callUnary('GetFieldAnalyticsSummary', request);
    return GetFieldAnalyticsSummaryResponse.fromBuffer(bytes);
  }
}
