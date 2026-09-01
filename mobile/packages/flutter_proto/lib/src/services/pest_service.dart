import '../generated/pest.pb.dart';
import 'base_service.dart';

/// ConnectRPC service client for pest prediction and management.
///
/// Provides operations for pest risk prediction, observation reporting,
/// treatment plans, and alert management.
class PestPredictionServiceClient extends BaseService {
  PestPredictionServiceClient({
    required super.baseUrl,
    super.httpClient,
    super.interceptors,
  });

  @override
  String get serviceName => 'agriculture.pest.v1.PestPredictionService';

  /// Predicts pest risk for a field.
  Future<PredictPestRiskResponse> predictPestRisk(
      PredictPestRiskRequest request) async {
    final bytes = await callUnary('PredictPestRisk', request);
    return PredictPestRiskResponse.fromBuffer(bytes);
  }

  /// Retrieves a pest prediction by ID.
  Future<GetPredictionResponse> getPrediction(String id) async {
    final request = GetPredictionRequest(id: id);
    final bytes = await callUnary('GetPrediction', request);
    return GetPredictionResponse.fromBuffer(bytes);
  }

  /// Lists pest predictions for a field.
  Future<ListPredictionsResponse> listPredictions({
    String? farmId,
    String? fieldId,
    int pageSize = 20,
    String pageToken = '',
  }) async {
    final request = ListPredictionsRequest(
      farmId: farmId,
      fieldId: fieldId,
      pageSize: pageSize,
      pageToken: pageToken,
    );
    final bytes = await callUnary('ListPredictions', request);
    return ListPredictionsResponse.fromBuffer(bytes);
  }

  /// Reports a pest observation.
  Future<ReportObservationResponse> reportObservation(
      ReportObservationRequest request) async {
    final bytes = await callUnary('ReportObservation', request);
    return ReportObservationResponse.fromBuffer(bytes);
  }

  /// Lists pest observations for a field.
  Future<ListObservationsResponse> listObservations({
    String? farmId,
    String? fieldId,
    int pageSize = 20,
    String pageToken = '',
  }) async {
    final request = ListObservationsRequest(
      farmId: farmId,
      fieldId: fieldId,
      pageSize: pageSize,
      pageToken: pageToken,
    );
    final bytes = await callUnary('ListObservations', request);
    return ListObservationsResponse.fromBuffer(bytes);
  }

  /// Retrieves a treatment plan for a prediction.
  Future<GetTreatmentPlanResponse> getTreatmentPlan(
      String predictionId) async {
    final request = GetTreatmentPlanRequest(predictionId: predictionId);
    final bytes = await callUnary('GetTreatmentPlan', request);
    return GetTreatmentPlanResponse.fromBuffer(bytes);
  }

  /// Retrieves the risk map.
  Future<GetRiskMapResponse> getRiskMap({
    String? pestSpeciesId,
    String? region,
  }) async {
    final request = GetRiskMapRequest(
      pestSpeciesId: pestSpeciesId,
      region: region,
    );
    final bytes = await callUnary('GetRiskMap', request);
    return GetRiskMapResponse.fromBuffer(bytes);
  }

  /// Lists active pest alerts for a farm.
  Future<ListAlertsResponse> listAlerts({
    required String farmId,
    String? fieldId,
    int pageSize = 20,
    String pageToken = '',
  }) async {
    final request = ListAlertsRequest(
      farmId: farmId,
      fieldId: fieldId,
      pageSize: pageSize,
      pageToken: pageToken,
    );
    final bytes = await callUnary('ListAlerts', request);
    return ListAlertsResponse.fromBuffer(bytes);
  }

  /// Acknowledges a pest alert.
  Future<AcknowledgeAlertResponse> acknowledgeAlert(String alertId) async {
    final request = AcknowledgeAlertRequest(id: alertId);
    final bytes = await callUnary('AcknowledgeAlert', request);
    return AcknowledgeAlertResponse.fromBuffer(bytes);
  }
}
