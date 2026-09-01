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
  String get serviceName => 'agriculture.diagnosis.v1.PlantDiagnosisService';

  /// Submits a crop image for AI diagnosis.
  Future<SubmitDiagnosisResponse> submitDiagnosis(
      SubmitDiagnosisRequest request) async {
    final bytes = await callUnary('SubmitDiagnosis', request);
    return SubmitDiagnosisResponse.fromBuffer(bytes);
  }

  /// Retrieves a previously computed diagnosis result by ID.
  Future<GetDiagnosisResponse> getDiagnosis(String id) async {
    final request = GetDiagnosisRequest(id: id);
    final bytes = await callUnary('GetDiagnosis', request);
    return GetDiagnosisResponse.fromBuffer(bytes);
  }

  /// Lists diagnosis history.
  Future<ListDiagnosesResponse> listDiagnoses({
    String? farmId,
    String? fieldId,
    int pageSize = 20,
    int pageOffset = 0,
  }) async {
    final request = ListDiagnosesRequest(
      farmId: farmId,
      fieldId: fieldId,
      pageSize: pageSize,
      pageOffset: pageOffset,
    );
    final bytes = await callUnary('ListDiagnoses', request);
    return ListDiagnosesResponse.fromBuffer(bytes);
  }
}
