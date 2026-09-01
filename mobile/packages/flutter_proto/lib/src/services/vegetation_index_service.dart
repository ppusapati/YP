import '../generated/vegetation_index.pb.dart';
import 'base_service.dart';

/// ConnectRPC service client for vegetation index computation.
///
/// Provides operations for computing vegetation indices, retrieving
/// NDVI time series, and assessing field health.
class VegetationIndexServiceClient extends BaseService {
  VegetationIndexServiceClient({
    required super.baseUrl,
    super.httpClient,
    super.interceptors,
  });

  @override
  String get serviceName =>
      'agriculture.satellite.vegetation.v1.VegetationIndexService';

  /// Computes vegetation indices.
  Future<ComputeIndicesResponse> computeIndices(
      ComputeIndicesRequest request) async {
    final bytes = await callUnary('ComputeIndices', request);
    return ComputeIndicesResponse.fromBuffer(bytes);
  }

  /// Retrieves a vegetation index by ID.
  Future<GetVegetationIndexResponse> getVegetationIndex(String id) async {
    final request = GetVegetationIndexRequest(id: id);
    final bytes = await callUnary('GetVegetationIndex', request);
    return GetVegetationIndexResponse.fromBuffer(bytes);
  }

  /// Lists vegetation indices.
  Future<ListVegetationIndicesResponse> listVegetationIndices({
    int pageSize = 20,
    String pageToken = '',
    String? farmId,
    String? fieldId,
  }) async {
    final request = ListVegetationIndicesRequest(
      pageSize: pageSize,
      pageToken: pageToken,
      farmId: farmId,
      fieldId: fieldId,
    );
    final bytes = await callUnary('ListVegetationIndices', request);
    return ListVegetationIndicesResponse.fromBuffer(bytes);
  }

  /// Retrieves NDVI time series for a field.
  Future<GetNDVITimeSeriesResponse> getNDVITimeSeries(
      String farmId, String fieldId) async {
    final request = GetNDVITimeSeriesRequest(
      farmId: farmId,
      fieldId: fieldId,
    );
    final bytes = await callUnary('GetNDVITimeSeries', request);
    return GetNDVITimeSeriesResponse.fromBuffer(bytes);
  }

  /// Retrieves field health assessment.
  Future<GetFieldHealthResponse> getFieldHealth(
      String farmId, String fieldId) async {
    final request = GetFieldHealthRequest(
      farmId: farmId,
      fieldId: fieldId,
    );
    final bytes = await callUnary('GetFieldHealth', request);
    return GetFieldHealthResponse.fromBuffer(bytes);
  }
}
