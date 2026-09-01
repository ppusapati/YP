import 'package:flutter_network/flutter_network.dart';

import '../models/advisory_model.dart';

/// Remote data source for crop advisory operations.
abstract class CropAdvisoryRemoteDataSource {
  Future<List<AdvisoryModel>> getAdvisories({String? farmId});
  Future<AdvisoryModel> getAdvisoryById(String id);
  Future<AdvisoryModel> createAdvisory(AdvisoryModel advisory);
}

class CropAdvisoryRemoteDataSourceImpl implements CropAdvisoryRemoteDataSource {
  final ConnectClient _client;

  CropAdvisoryRemoteDataSourceImpl(this._client);

  // No generated protobuf types exist for agriculture.agronomy.v1.AdvisoryService.
  // All methods throw UnimplementedError until proto definitions are available.

  @override
  Future<List<AdvisoryModel>> getAdvisories({String? farmId}) {
    throw UnimplementedError(
      'AdvisoryService/ListAdvisories has no generated protobuf request type',
    );
  }

  @override
  Future<AdvisoryModel> getAdvisoryById(String id) {
    throw UnimplementedError(
      'AdvisoryService/GetAdvisory has no generated protobuf request type',
    );
  }

  @override
  Future<AdvisoryModel> createAdvisory(AdvisoryModel advisory) {
    throw UnimplementedError(
      'AdvisoryService/CreateAdvisory has no generated protobuf request type',
    );
  }
}
