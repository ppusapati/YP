import '../generated/crop.pb.dart';
import 'base_service.dart';

/// ConnectRPC service client for crop management.
///
/// Provides CRUD operations for crops, varieties, growth stages,
/// and crop requirements.
class CropServiceClient extends BaseService {
  CropServiceClient({
    required super.baseUrl,
    super.httpClient,
    super.interceptors,
  });

  @override
  String get serviceName => 'agriculture.crop.v1.CropService';

  /// Retrieves a crop by ID.
  Future<GetCropResponse> getCrop(String id) async {
    final request = GetCropRequest(id: id);
    final bytes = await callUnary('GetCrop', request);
    return GetCropResponse.fromBuffer(bytes);
  }

  /// Lists all crops.
  Future<ListCropsResponse> listCrops({
    int pageSize = 20,
    int pageOffset = 0,
  }) async {
    final request = ListCropsRequest(
      pageSize: pageSize,
      pageOffset: pageOffset,
    );
    final bytes = await callUnary('ListCrops', request);
    return ListCropsResponse.fromBuffer(bytes);
  }

  /// Creates a new crop.
  Future<CreateCropResponse> createCrop(CreateCropRequest request) async {
    final bytes = await callUnary('CreateCrop', request);
    return CreateCropResponse.fromBuffer(bytes);
  }

  /// Updates an existing crop.
  Future<UpdateCropResponse> updateCrop(UpdateCropRequest request) async {
    final bytes = await callUnary('UpdateCrop', request);
    return UpdateCropResponse.fromBuffer(bytes);
  }

  /// Deletes a crop by ID.
  Future<void> deleteCrop(String id) async {
    final request = DeleteCropRequest(id: id);
    await callUnary('DeleteCrop', request);
  }

  /// Adds a variety to a crop.
  Future<AddVarietyResponse> addVariety(AddVarietyRequest request) async {
    final bytes = await callUnary('AddVariety', request);
    return AddVarietyResponse.fromBuffer(bytes);
  }

  /// Lists all varieties for a crop.
  Future<ListVarietiesResponse> listVarieties(String cropId) async {
    final request = ListVarietiesRequest(cropId: cropId);
    final bytes = await callUnary('ListVarieties', request);
    return ListVarietiesResponse.fromBuffer(bytes);
  }

  /// Retrieves growth stages for a crop.
  Future<GetGrowthStagesResponse> getGrowthStages(String cropId) async {
    final request = GetGrowthStagesRequest(cropId: cropId);
    final bytes = await callUnary('GetGrowthStages', request);
    return GetGrowthStagesResponse.fromBuffer(bytes);
  }

  /// Retrieves crop requirements for a crop.
  Future<GetCropRequirementsResponse> getCropRequirements(
      String cropId) async {
    final request = GetCropRequirementsRequest(cropId: cropId);
    final bytes = await callUnary('GetCropRequirements', request);
    return GetCropRequirementsResponse.fromBuffer(bytes);
  }

  /// Generates a crop recommendation.
  Future<GenerateRecommendationResponse> generateRecommendation(
      GenerateRecommendationRequest request) async {
    final bytes = await callUnary('GenerateRecommendation', request);
    return GenerateRecommendationResponse.fromBuffer(bytes);
  }
}
