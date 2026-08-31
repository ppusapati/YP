import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_network/flutter_network.dart';
import 'package:logging/logging.dart';

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
  final _log = Logger('FarmRemoteDataSource');

  FarmRemoteDataSourceImpl(this._client);

  Future<Map<String, dynamic>> _post(
      String service, String method, Map<String, dynamic> body) async {
    final path = '/yieldpoint.agronomy.v1.$service/$method';
    _log.fine('POST $path');

    final response = await _client.unary(
      path,
      body: Uint8List.fromList(utf8.encode(jsonEncode(body))),
      headers: {'Content-Type': 'application/json'},
    );

    if (!response.isSuccess) {
      throw FarmRemoteException(
        'RPC call $service/$method failed',
        statusCode: response.statusCode,
      );
    }

    return jsonDecode(utf8.decode(response.body)) as Map<String, dynamic>;
  }

  @override
  Future<List<FarmModel>> getFarms() async {
    final data = await _post('FarmService', 'ListFarms', {});
    final farms = data['farms'] as List<dynamic>? ?? [];
    return farms
        .map((f) => FarmModel.fromJson(f as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<FarmModel> getFarmById(String farmId) async {
    final data = await _post('FarmService', 'GetFarm', {'id': farmId});
    return FarmModel.fromJson(data['farm'] as Map<String, dynamic>);
  }

  @override
  Future<FarmModel> createFarm(FarmModel farm) async {
    final data = await _post('FarmService', 'CreateFarm', {
      'farm': farm.toJson(),
    });
    return FarmModel.fromJson(data['farm'] as Map<String, dynamic>);
  }

  @override
  Future<FarmModel> updateFarm(FarmModel farm) async {
    final data = await _post('FarmService', 'UpdateFarm', {
      'farm': farm.toJson(),
    });
    return FarmModel.fromJson(data['farm'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteFarm(String farmId) async {
    await _post('FarmService', 'DeleteFarm', {'id': farmId});
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
