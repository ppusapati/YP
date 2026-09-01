import '../generated/satellite.pb.dart';
import 'base_service.dart';

/// ConnectRPC service client for satellite imagery and analysis.
///
/// Provides access to satellite imagery, vegetation index computation,
/// crop stress detection, and temporal analysis.
class SatelliteServiceClient extends BaseService {
  SatelliteServiceClient({
    required super.baseUrl,
    super.httpClient,
    super.interceptors,
  });

  @override
  String get serviceName => 'agriculture.satellite.v1.SatelliteService';

  /// Requests new satellite imagery for a field.
  Future<RequestImageryResponse> requestImagery(
      RequestImageryRequest request) async {
    final bytes = await callUnary('RequestImagery', request);
    return RequestImageryResponse.fromBuffer(bytes);
  }

  /// Retrieves a satellite image by ID.
  Future<GetImageResponse> getImage(String id) async {
    final request = GetImageRequest(id: id);
    final bytes = await callUnary('GetImage', request);
    return GetImageResponse.fromBuffer(bytes);
  }

  /// Lists satellite images for a field.
  Future<ListImagesResponse> listImages({
    required String fieldId,
    String? farmId,
    int pageSize = 20,
    int pageOffset = 0,
  }) async {
    final request = ListImagesRequest(
      fieldId: fieldId,
      farmId: farmId,
      pageSize: pageSize,
      pageOffset: pageOffset,
    );
    final bytes = await callUnary('ListImages', request);
    return ListImagesResponse.fromBuffer(bytes);
  }

  /// Computes a vegetation index for an image.
  Future<ComputeIndexResponse> computeIndex({
    required String imageId,
    required String fieldId,
  }) async {
    final request = ComputeIndexRequest(
      imageId: imageId,
      fieldId: fieldId,
    );
    final bytes = await callUnary('ComputeIndex', request);
    return ComputeIndexResponse.fromBuffer(bytes);
  }

  /// Retrieves vegetation indices for an image.
  Future<GetVegetationIndicesResponse> getVegetationIndices({
    required String imageId,
    required String fieldId,
    String? indexType,
  }) async {
    final request = GetVegetationIndicesRequest(
      imageId: imageId,
      fieldId: fieldId,
      indexType: indexType,
    );
    final bytes = await callUnary('GetVegetationIndices', request);
    return GetVegetationIndicesResponse.fromBuffer(bytes);
  }

  /// Detects crop stress for a field from an image.
  Future<DetectCropStressResponse> detectCropStress({
    required String imageId,
    required String fieldId,
  }) async {
    final request = DetectCropStressRequest(
      imageId: imageId,
      fieldId: fieldId,
    );
    final bytes = await callUnary('DetectCropStress', request);
    return DetectCropStressResponse.fromBuffer(bytes);
  }

  /// Retrieves temporal analysis for a field.
  Future<GetTemporalAnalysisResponse> getTemporalAnalysis(
      GetTemporalAnalysisRequest request) async {
    final bytes = await callUnary('GetTemporalAnalysis', request);
    return GetTemporalAnalysisResponse.fromBuffer(bytes);
  }

  /// Lists satellite alerts for a field.
  Future<ListAlertsResponse> listAlerts({
    required String fieldId,
    int pageSize = 20,
    int pageOffset = 0,
  }) async {
    final request = ListAlertsRequest(
      fieldId: fieldId,
      pageSize: pageSize,
      pageOffset: pageOffset,
    );
    final bytes = await callUnary('ListAlerts', request);
    return ListAlertsResponse.fromBuffer(bytes);
  }
}
