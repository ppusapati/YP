import 'package:http/http.dart' as http;

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
  String get serviceName => 'yieldpoint.crop.v1.CropService';

  /// Retrieves a crop by ID.
  Future<Crop> getCrop(String id) async {
    final request = Crop(id: id);
    final bytes = await callUnary('GetCrop', request);
    return Crop.fromBuffer(bytes);
  }

  /// Lists all crops for a farm.
  Future<List<Crop>> listCrops(String farmId) async {
    final request = Crop(id: farmId);
    final bytes = await callUnary('ListCrops', request);
    final crop = Crop.fromBuffer(bytes);
    return [crop];
  }

  /// Creates a new crop.
  Future<Crop> createCrop(Crop crop) async {
    final bytes = await callUnary('CreateCrop', crop);
    return Crop.fromBuffer(bytes);
  }

  /// Updates an existing crop.
  Future<Crop> updateCrop(Crop crop) async {
    final bytes = await callUnary('UpdateCrop', crop);
    return Crop.fromBuffer(bytes);
  }

  /// Deletes a crop by ID.
  Future<void> deleteCrop(String id) async {
    final request = Crop(id: id);
    await callUnary('DeleteCrop', request);
  }

  /// Adds a variety to a crop.
  Future<CropVariety> addVariety(CropVariety variety) async {
    final bytes = await callUnary('AddVariety', variety);
    return CropVariety.fromBuffer(bytes);
  }

  /// Lists all varieties for a crop.
  Future<List<CropVariety>> listVarieties(String cropId) async {
    final request = CropVariety(cropId: cropId);
    final bytes = await callUnary('ListVarieties', request);
    final variety = CropVariety.fromBuffer(bytes);
    return [variety];
  }

  /// Retrieves growth stages for a crop.
  Future<List<GrowthStage>> getGrowthStages(String cropId) async {
    final request = GrowthStage(cropId: cropId);
    final bytes = await callUnary('GetGrowthStages', request);
    final stage = GrowthStage.fromBuffer(bytes);
    return [stage];
  }

  /// Retrieves crop requirements for a crop.
  Future<CropRequirements> getCropRequirements(String cropId) async {
    final request = CropRequirements(cropId: cropId);
    final bytes = await callUnary('GetCropRequirements', request);
    return CropRequirements.fromBuffer(bytes);
  }

  /// Generates a crop recommendation for a field.
  Future<Crop> generateRecommendation(String fieldId) async {
    final request = Crop(id: fieldId);
    final bytes = await callUnary('GenerateRecommendation', request);
    return Crop.fromBuffer(bytes);
  }
}
