import 'package:http/http.dart' as http;

import '../generated/crop_recommendation.pb.dart';
import '../generated/soil.pb.dart';
import '../generated/yield.pb.dart';
import 'base_service.dart';

/// ConnectRPC service client for yield predictions and crop recommendations.
///
/// Provides access to yield predictions, contributing factors,
/// soil analysis, and crop recommendations.
class YieldServiceClient extends BaseService {
  YieldServiceClient({
    required super.baseUrl,
    super.httpClient,
    super.interceptors,
  });

  @override
  String get serviceName => 'yieldpoint.yield.v1.YieldService';

  /// Retrieves the latest yield prediction for a field.
  Future<YieldPrediction> getYieldPrediction(String fieldId) async {
    final request = YieldPrediction(fieldId: fieldId);
    final bytes = await callUnary('GetYieldPrediction', request);
    return YieldPrediction.fromBuffer(bytes);
  }

  /// Lists yield predictions for a field over time.
  Future<List<YieldPrediction>> listYieldPredictions({
    required String fieldId,
    String? cropType,
    int pageSize = 20,
  }) async {
    final request = YieldPrediction(fieldId: fieldId, cropType: cropType);
    final bytes = await callUnary('ListYieldPredictions', request);
    final prediction = YieldPrediction.fromBuffer(bytes);
    return [prediction];
  }

  /// Retrieves the latest soil analysis for a field.
  Future<SoilAnalysis> getSoilAnalysis(String fieldId) async {
    final request = SoilAnalysis(fieldId: fieldId);
    final bytes = await callUnary('GetSoilAnalysis', request);
    return SoilAnalysis.fromBuffer(bytes);
  }

  /// Submits a new soil analysis for a field.
  Future<SoilAnalysis> submitSoilAnalysis(SoilAnalysis analysis) async {
    final bytes = await callUnary('SubmitSoilAnalysis', analysis);
    return SoilAnalysis.fromBuffer(bytes);
  }

  /// Retrieves crop recommendations for a field based on soil and climate data.
  Future<List<CropRecommendation>> getCropRecommendations(
    String fieldId,
  ) async {
    final request = CropRecommendation(cropName: fieldId);
    final bytes = await callUnary('GetCropRecommendations', request);
    final rec = CropRecommendation.fromBuffer(bytes);
    return [rec];
  }

  /// Streams real-time yield prediction updates for a field.
  Stream<YieldPrediction> streamYieldUpdates(String fieldId) {
    final request = YieldPrediction(fieldId: fieldId);
    return callServerStream('StreamYieldUpdates', request)
        .map((bytes) => YieldPrediction.fromBuffer(bytes));
  }
}
