import 'package:http/http.dart' as http;

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
      'yieldpoint.satellite.analytics.v1.SatelliteAnalyticsService';

  /// Detects stress in a field.
  Future<StressAlert> detectStress(StressAlert request) async {
    final bytes = await callUnary('DetectStress', request);
    return StressAlert.fromBuffer(bytes);
  }

  /// Lists stress alerts for a farm.
  Future<List<StressAlert>> listStressAlerts(String farmId) async {
    final request = StressAlert(farmId: farmId);
    final bytes = await callUnary('ListStressAlerts', request);
    final alert = StressAlert.fromBuffer(bytes);
    return [alert];
  }

  /// Retrieves a stress alert by ID.
  Future<StressAlert> getStressAlert(String id) async {
    final request = StressAlert(id: id);
    final bytes = await callUnary('GetStressAlert', request);
    return StressAlert.fromBuffer(bytes);
  }

  /// Acknowledges a stress alert.
  Future<void> acknowledgeAlert(String id) async {
    final request = StressAlert(id: id);
    await callUnary('AcknowledgeAlert', request);
  }

  /// Runs a temporal analysis over a time period.
  Future<TemporalAnalysisResult> runTemporalAnalysis(
      TemporalAnalysisResult request) async {
    final bytes = await callUnary('RunTemporalAnalysis', request);
    return TemporalAnalysisResult.fromBuffer(bytes);
  }

  /// Retrieves analytics summary for a field.
  Future<FieldAnalyticsSummary> getFieldAnalyticsSummary(
      String farmId, String fieldId) async {
    final request = FieldAnalyticsSummary(farmId: farmId, fieldId: fieldId);
    final bytes = await callUnary('GetFieldAnalyticsSummary', request);
    return FieldAnalyticsSummary.fromBuffer(bytes);
  }
}
