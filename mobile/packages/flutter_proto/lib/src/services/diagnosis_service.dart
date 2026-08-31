import 'package:http/http.dart' as http;

import '../generated/diagnosis.pb.dart';
import 'base_service.dart';

/// ConnectRPC service client for AI crop diagnosis.
///
/// Submits crop images for analysis and returns disease identification,
/// confidence scores, and treatment recommendations.
class DiagnosisServiceClient extends BaseService {
  DiagnosisServiceClient({
    required super.baseUrl,
    super.httpClient,
    super.interceptors,
  });

  @override
  String get serviceName => 'yieldpoint.diagnosis.v1.DiagnosisService';

  /// Submits a crop image for AI diagnosis.
  ///
  /// Returns a [DiagnosisResult] containing the identified plant species,
  /// disease type, confidence score, severity, and recommended treatments.
  Future<DiagnosisResult> diagnose(DiagnosisRequest request) async {
    final bytes = await callUnary('Diagnose', request);
    return DiagnosisResult.fromBuffer(bytes);
  }

  /// Retrieves a previously computed diagnosis result by ID.
  Future<DiagnosisResult> getDiagnosisResult(String resultId) async {
    final request = DiagnosisResult(plantSpecies: resultId);
    final bytes = await callUnary('GetDiagnosisResult', request);
    return DiagnosisResult.fromBuffer(bytes);
  }

  /// Lists diagnosis history for a given crop type and location.
  Future<List<DiagnosisResult>> listDiagnoses({
    required String cropType,
    double? latitude,
    double? longitude,
    int pageSize = 20,
  }) async {
    final request = DiagnosisRequest(
      cropType: cropType,
      latitude: latitude,
      longitude: longitude,
    );
    final bytes = await callUnary('ListDiagnoses', request);
    final result = DiagnosisResult.fromBuffer(bytes);
    return [result];
  }
}
