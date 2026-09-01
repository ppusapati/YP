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
  String get serviceName => 'agriculture.soil.v1.SoilService';

  /// Retrieves a soil sample by ID.
  Future<GetSoilSampleResponse> getSoilSample(String id) async {
    final request = GetSoilSampleRequest(id: id);
    final bytes = await callUnary('GetSoilSample', request);
    return GetSoilSampleResponse.fromBuffer(bytes);
  }

  /// Lists soil samples for a field.
  Future<ListSoilSamplesResponse> listSoilSamples({
    required String fieldId,
    String? farmId,
    int pageSize = 20,
    int pageOffset = 0,
  }) async {
    final request = ListSoilSamplesRequest(
      fieldId: fieldId,
      farmId: farmId,
      pageSize: pageSize,
      pageOffset: pageOffset,
    );
    final bytes = await callUnary('ListSoilSamples', request);
    return ListSoilSamplesResponse.fromBuffer(bytes);
  }

  /// Creates a new soil sample.
  Future<CreateSoilSampleResponse> createSoilSample(
      CreateSoilSampleRequest request) async {
    final bytes = await callUnary('CreateSoilSample', request);
    return CreateSoilSampleResponse.fromBuffer(bytes);
  }

  /// Runs soil analysis for a sample.
  Future<AnalyzeSoilResponse> analyzeSoil(String sampleId) async {
    final request = AnalyzeSoilRequest(sampleId: sampleId);
    final bytes = await callUnary('AnalyzeSoil', request);
    return AnalyzeSoilResponse.fromBuffer(bytes);
  }

  /// Retrieves soil health assessment for a field.
  Future<GetSoilHealthResponse> getSoilHealth(String fieldId) async {
    final request = GetSoilHealthRequest(fieldId: fieldId);
    final bytes = await callUnary('GetSoilHealth', request);
    return GetSoilHealthResponse.fromBuffer(bytes);
  }

  /// Retrieves nutrient levels for a sample.
  Future<GetNutrientLevelsResponse> getNutrientLevels(
      String sampleId) async {
    final request = GetNutrientLevelsRequest(sampleId: sampleId);
    final bytes = await callUnary('GetNutrientLevels', request);
    return GetNutrientLevelsResponse.fromBuffer(bytes);
  }

  /// Generates a soil report for a field.
  Future<GenerateSoilReportResponse> generateSoilReport({
    required String fieldId,
    String? farmId,
  }) async {
    final request = GenerateSoilReportRequest(
      fieldId: fieldId,
      farmId: farmId,
    );
    final bytes = await callUnary('GenerateSoilReport', request);
    return GenerateSoilReportResponse.fromBuffer(bytes);
  }
}
