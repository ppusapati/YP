import 'package:flutter_network/flutter_network.dart';
import 'package:flutter_proto/src/generated/farm.pb.dart' as farm_pb;
import 'package:protobuf/protobuf.dart' as $pb;

import '../models/farm_model.dart';

/// Remote data source for farm operations using ConnectRPC.
abstract class FarmRemoteDataSource {
  Future<List<FarmModel>> getFarms();
  Future<FarmModel> getFarmById(String farmId);
  Future<FarmModel> createFarm(FarmModel farm);
  Future<FarmModel> updateFarm(FarmModel farm);
  Future<void> deleteFarm(String farmId);
}

/// ConnectRPC-based implementation of [FarmRemoteDataSource].
class FarmRemoteDataSourceImpl implements FarmRemoteDataSource {
  final ConnectClient _client;

  static const _basePath = '/agriculture.farm.v1.FarmService';

  FarmRemoteDataSourceImpl(this._client);

  Future<ConnectResponse> _call(
      String method, $pb.GeneratedMessage request) async {
    final response = await _client.unary(
      '$_basePath/$method',
      body: request.writeToBuffer(),
    );
    if (!response.isSuccess) {
      throw FarmRemoteException(
        'RPC call FarmService/$method failed',
        statusCode: response.statusCode,
      );
    }
    return response;
  }

  @override
  Future<List<FarmModel>> getFarms() async {
    final request = farm_pb.ListFarmsRequest();
    final response = await _call('ListFarms', request);
    final pbResponse = farm_pb.ListFarmsResponse.fromBuffer(response.body);
    return pbResponse.farms.map(_farmFromProto).toList();
  }

  @override
  Future<FarmModel> getFarmById(String farmId) async {
    final request = farm_pb.GetFarmRequest(id: farmId);
    final response = await _call('GetFarm', request);
    final pbResponse = farm_pb.GetFarmResponse.fromBuffer(response.body);
    return _farmFromProto(pbResponse.farm);
  }

  @override
  Future<FarmModel> createFarm(FarmModel farm) async {
    final request = farm_pb.CreateFarmRequest(
      name: farm.name,
      description: farm.location,
      totalAreaHectares: farm.areaHectares,
    );
    final response = await _call('CreateFarm', request);
    final pbResponse = farm_pb.CreateFarmResponse.fromBuffer(response.body);
    return _farmFromProto(pbResponse.farm);
  }

  @override
  Future<FarmModel> updateFarm(FarmModel farm) async {
    final request = farm_pb.UpdateFarmRequest(
      id: farm.id,
      name: farm.name,
      description: farm.location,
      totalAreaHectares: farm.areaHectares,
    );
    final response = await _call('UpdateFarm', request);
    final pbResponse = farm_pb.UpdateFarmResponse.fromBuffer(response.body);
    return _farmFromProto(pbResponse.farm);
  }

  @override
  Future<void> deleteFarm(String farmId) async {
    final request = farm_pb.DeleteFarmRequest(id: farmId);
    await _call('DeleteFarm', request);
  }

  /// Converts a protobuf [farm_pb.Farm] to a [FarmModel].
  static FarmModel _farmFromProto(farm_pb.Farm pb) {
    final owners = pb.owners;
    final ownerName =
        owners.isNotEmpty ? owners.first.ownerName : '';
    final createdAt = pb.hasCreatedAt()
        ? DateTime.fromMillisecondsSinceEpoch(
            pb.createdAt.seconds.toInt() * 1000)
        : DateTime.now();
    final updatedAt = pb.hasUpdatedAt()
        ? DateTime.fromMillisecondsSinceEpoch(
            pb.updatedAt.seconds.toInt() * 1000)
        : DateTime.now();
    return FarmModel(
      id: pb.id,
      name: pb.name,
      location: pb.address.isNotEmpty ? pb.address : pb.description,
      areaHectares: pb.totalAreaHectares,
      ownerName: ownerName,
      fieldCount: 0,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// Exception thrown when a remote farm API call fails.
class FarmRemoteException implements Exception {
  final String message;
  final int? statusCode;

  const FarmRemoteException(this.message, {this.statusCode});

  @override
  String toString() => 'FarmRemoteException($message, statusCode: $statusCode)';
}
