import 'package:http/http.dart' as http;

import '../generated/soil.pb.dart';
import 'base_service.dart';

/// ConnectRPC service client for soil analysis.
///
/// Provides operations for soil sampling, analysis, health assessment,
/// and nutrient level monitoring.
class SoilServiceClient extends BaseService {
  SoilServiceClient({
    required super.baseUrl,
    super.httpClient,
    super.interceptors,
  });

  @override
  String get serviceName => 'yieldpoint.soil.v1.SoilService';

  /// Retrieves a soil sample by ID.
  Future<SoilAnalysis> getSoilSample(String id) async {
    final request = SoilAnalysis(fieldId: id);
    final bytes = await callUnary('GetSoilSample', request);
    return SoilAnalysis.fromBuffer(bytes);
  }

  /// Lists all soil samples for a field.
  Future<List<SoilAnalysis>> listSoilSamples(String fieldId) async {
    final request = SoilAnalysis(fieldId: fieldId);
    final bytes = await callUnary('ListSoilSamples', request);
    final sample = SoilAnalysis.fromBuffer(bytes);
    return [sample];
  }

  /// Creates a new soil sample.
  Future<SoilAnalysis> createSoilSample(SoilAnalysis sample) async {
    final bytes = await callUnary('CreateSoilSample', sample);
    return SoilAnalysis.fromBuffer(bytes);
  }

  /// Runs soil analysis for a field.
  Future<SoilAnalysis> analyzeSoil(String fieldId) async {
    final request = SoilAnalysis(fieldId: fieldId);
    final bytes = await callUnary('AnalyzeSoil', request);
    return SoilAnalysis.fromBuffer(bytes);
  }

  /// Retrieves soil health assessment for a field.
  Future<SoilAnalysis> getSoilHealth(String fieldId) async {
    final request = SoilAnalysis(fieldId: fieldId);
    final bytes = await callUnary('GetSoilHealth', request);
    return SoilAnalysis.fromBuffer(bytes);
  }

  /// Retrieves nutrient levels for a field.
  Future<SoilAnalysis> getNutrientLevels(String fieldId) async {
    final request = SoilAnalysis(fieldId: fieldId);
    final bytes = await callUnary('GetNutrientLevels', request);
    return SoilAnalysis.fromBuffer(bytes);
  }

  /// Generates a soil report for a field.
  Future<SoilAnalysis> generateSoilReport(String fieldId) async {
    final request = SoilAnalysis(fieldId: fieldId);
    final bytes = await callUnary('GenerateSoilReport', request);
    return SoilAnalysis.fromBuffer(bytes);
  }
}
