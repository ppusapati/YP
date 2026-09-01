import 'dart:typed_data';

import 'package:protobuf/protobuf.dart' as $pb;

import '../generated/farm.pb.dart';
import 'base_service.dart';

class FarmServiceClient extends BaseService {
  FarmServiceClient({
    required super.baseUrl,
    super.httpClient,
    super.interceptors,
  });

  @override
  String get serviceName => 'agriculture.farm.v1.FarmService';

  Future<GetFarmResponse> getFarm(String farmId) async {
    final request = GetFarmRequest(id: farmId);
    final bytes = await callUnary('GetFarm', request);
    return GetFarmResponse.fromBuffer(bytes);
  }

  Future<ListFarmsResponse> listFarms({
    int pageSize = 20,
    String pageToken = '',
  }) async {
    final request = ListFarmsRequest(pageSize: pageSize, pageToken: pageToken);
    final bytes = await callUnary('ListFarms', request);
    return ListFarmsResponse.fromBuffer(bytes);
  }

  Future<CreateFarmResponse> createFarm(CreateFarmRequest request) async {
    final bytes = await callUnary('CreateFarm', request);
    return CreateFarmResponse.fromBuffer(bytes);
  }

  Future<UpdateFarmResponse> updateFarm(UpdateFarmRequest request) async {
    final bytes = await callUnary('UpdateFarm', request);
    return UpdateFarmResponse.fromBuffer(bytes);
  }

  Future<void> deleteFarm(String farmId) async {
    final request = DeleteFarmRequest(id: farmId);
    await callUnary('DeleteFarm', request);
  }
}
