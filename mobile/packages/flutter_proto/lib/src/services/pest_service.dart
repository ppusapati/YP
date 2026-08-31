import 'package:http/http.dart' as http;

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
  String get serviceName => 'yieldpoint.pest.v1.PestPredictionService';

  /// Predicts pest risk for a field.
  Future<PestRiskZone> predictPestRisk(String fieldId) async {
    final request = PestRiskZone(fieldId: fieldId);
    final bytes = await callUnary('PredictPestRisk', request);
    return PestRiskZone.fromBuffer(bytes);
  }

  /// Retrieves a pest prediction by ID.
  Future<PestRiskZone> getPrediction(String id) async {
    final request = PestRiskZone(id: id);
    final bytes = await callUnary('GetPrediction', request);
    return PestRiskZone.fromBuffer(bytes);
  }

  /// Lists all pest predictions for a field.
  Future<List<PestRiskZone>> listPredictions(String fieldId) async {
    final request = PestRiskZone(fieldId: fieldId);
    final bytes = await callUnary('ListPredictions', request);
    final zone = PestRiskZone.fromBuffer(bytes);
    return [zone];
  }

  /// Reports a pest observation.
  Future<PestRiskZone> reportObservation(PestRiskZone obs) async {
    final bytes = await callUnary('ReportObservation', obs);
    return PestRiskZone.fromBuffer(bytes);
  }

  /// Lists all pest observations for a field.
  Future<List<PestRiskZone>> listObservations(String fieldId) async {
    final request = PestRiskZone(fieldId: fieldId);
    final bytes = await callUnary('ListObservations', request);
    final zone = PestRiskZone.fromBuffer(bytes);
    return [zone];
  }

  /// Retrieves a treatment plan for a prediction.
  Future<PestRiskZone> getTreatmentPlan(String predictionId) async {
    final request = PestRiskZone(id: predictionId);
    final bytes = await callUnary('GetTreatmentPlan', request);
    return PestRiskZone.fromBuffer(bytes);
  }

  /// Retrieves the risk map for a farm.
  Future<List<PestRiskZone>> getRiskMap(String farmId) async {
    final request = PestRiskZone(fieldId: farmId);
    final bytes = await callUnary('GetRiskMap', request);
    final zone = PestRiskZone.fromBuffer(bytes);
    return [zone];
  }

  /// Lists all active pest alerts for a farm.
  Future<List<PestRiskZone>> listAlerts(String farmId) async {
    final request = PestRiskZone(fieldId: farmId);
    final bytes = await callUnary('ListAlerts', request);
    final zone = PestRiskZone.fromBuffer(bytes);
    return [zone];
  }

  /// Acknowledges a pest alert.
  Future<void> acknowledgeAlert(String alertId) async {
    final request = PestRiskZone(id: alertId);
    await callUnary('AcknowledgeAlert', request);
  }
}
