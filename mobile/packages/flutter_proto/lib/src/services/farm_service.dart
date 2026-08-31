import 'package:http/http.dart' as http;

import '../generated/farm.pb.dart';
import 'base_service.dart';

/// Request message for getting a farm by ID.
class GetFarmRequest {
  const GetFarmRequest({required this.id});
  final String id;
}

/// Request message for listing farms owned by a user.
class ListFarmsRequest {
  const ListFarmsRequest({required this.ownerId, this.pageSize = 20, this.pageToken = ''});
  final String ownerId;
  final int pageSize;
  final String pageToken;
}

/// Response message for listing farms.
class ListFarmsResponse {
  const ListFarmsResponse({required this.farms, this.nextPageToken = ''});
  final List<Farm> farms;
  final String nextPageToken;
}

/// ConnectRPC service client for farm operations.
///
/// Provides CRUD operations for farms and fields, including
/// boundary management and farm metadata.
class FarmServiceClient extends BaseService {
  FarmServiceClient({
    required super.baseUrl,
    super.httpClient,
    super.interceptors,
  });

  @override
  String get serviceName => 'yieldpoint.farm.v1.FarmService';

  /// Retrieves a farm by its unique identifier.
  Future<Farm> getFarm(String farmId) async {
    final request = Farm(id: farmId);
    final bytes = await callUnary('GetFarm', request);
    return Farm.fromBuffer(bytes);
  }

  /// Lists all farms belonging to [ownerId].
  Future<ListFarmsResponse> listFarms({
    required String ownerId,
    int pageSize = 20,
    String pageToken = '',
  }) async {
    final request = Farm(ownerId: ownerId);
    final bytes = await callUnary('ListFarms', request);
    // In a real implementation, the response would be a dedicated
    // ListFarmsResponse protobuf message. Here we simulate it.
    final farm = Farm.fromBuffer(bytes);
    return ListFarmsResponse(farms: [farm]);
  }

  /// Creates a new farm and returns it with a server-assigned ID.
  Future<Farm> createFarm(Farm farm) async {
    final bytes = await callUnary('CreateFarm', farm);
    return Farm.fromBuffer(bytes);
  }

  /// Updates an existing farm. Only fields present in the request are updated.
  Future<Farm> updateFarm(Farm farm) async {
    final bytes = await callUnary('UpdateFarm', farm);
    return Farm.fromBuffer(bytes);
  }

  /// Permanently deletes a farm by ID.
  Future<void> deleteFarm(String farmId) async {
    final request = Farm(id: farmId);
    await callUnary('DeleteFarm', request);
  }

  /// Retrieves a field by its unique identifier.
  Future<Field> getField(String fieldId) async {
    final request = Field(id: fieldId);
    final bytes = await callUnary('GetField', request);
    return Field.fromBuffer(bytes);
  }

  /// Lists all fields belonging to a farm.
  Future<List<Field>> listFields(String farmId) async {
    final request = Field(farmId: farmId);
    final bytes = await callUnary('ListFields', request);
    final field = Field.fromBuffer(bytes);
    return [field];
  }

  /// Creates a new field within a farm.
  Future<Field> createField(Field field) async {
    final bytes = await callUnary('CreateField', field);
    return Field.fromBuffer(bytes);
  }

  /// Updates an existing field.
  Future<Field> updateField(Field field) async {
    final bytes = await callUnary('UpdateField', field);
    return Field.fromBuffer(bytes);
  }

  /// Permanently deletes a field by ID.
  Future<void> deleteField(String fieldId) async {
    final request = Field(id: fieldId);
    await callUnary('DeleteField', request);
  }
}
