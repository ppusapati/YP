import '../generated/yield.pb.dart';
import 'base_service.dart';

/// ConnectRPC service client for yield predictions.
///
/// Provides access to yield predictions, history,
/// and real-time yield prediction updates.
class YieldServiceClient extends BaseService {
  YieldServiceClient({
    required super.baseUrl,
    super.httpClient,
    super.interceptors,
  });

  @override
  String get serviceName => 'agriculture.yield.v1.YieldService';

  /// Predicts yield for a field.
  Future<PredictYieldResponse> predictYield(
      PredictYieldRequest request) async {
    final bytes = await callUnary('PredictYield', request);
    return PredictYieldResponse.fromBuffer(bytes);
  }

  /// Retrieves a yield prediction by ID.
  Future<GetPredictionResponse> getPrediction(String id) async {
    final request = GetPredictionRequest(id: id);
    final bytes = await callUnary('GetPrediction', request);
    return GetPredictionResponse.fromBuffer(bytes);
  }

  /// Lists yield predictions.
  Future<ListPredictionsResponse> listPredictions({
    String? farmId,
    String? fieldId,
    String? cropId,
    int pageSize = 20,
    String pageToken = '',
  }) async {
    final request = ListPredictionsRequest(
      farmId: farmId,
      fieldId: fieldId,
      cropId: cropId,
      pageSize: pageSize,
      pageToken: pageToken,
    );
    final bytes = await callUnary('ListPredictions', request);
    return ListPredictionsResponse.fromBuffer(bytes);
  }

  /// Retrieves yield history for a field.
  Future<GetYieldHistoryResponse> getYieldHistory({
    required String fieldId,
    String? farmId,
    String? cropId,
    int pageSize = 20,
    String pageToken = '',
  }) async {
    final request = GetYieldHistoryRequest(
      fieldId: fieldId,
      farmId: farmId,
      cropId: cropId,
      pageSize: pageSize,
      pageToken: pageToken,
    );
    final bytes = await callUnary('GetYieldHistory', request);
    return GetYieldHistoryResponse.fromBuffer(bytes);
  }

  /// Streams real-time yield prediction updates for a field.
  Stream<YieldPrediction> streamYieldUpdates(String fieldId) {
    final request = PredictYieldRequest(fieldId: fieldId);
    return callServerStream('StreamYieldUpdates', request)
        .map((bytes) => YieldPrediction.fromBuffer(bytes));
  }
}
