import 'dart:convert';

import 'package:flutter_network/flutter_network.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import '../models/farm_model.dart';
import '../models/field_model.dart';

/// Remote data source for farm operations using ConnectRPC.
abstract class FarmRemoteDataSource {
  Future<List<FarmModel>> getFarms(String userId);
  Future<FarmModel> getFarmById(String farmId);
  Future<FarmModel> createFarm(FarmModel farm);
  Future<FarmModel> updateFarm(FarmModel farm);
  Future<void> deleteFarm(String farmId);
  Future<FieldModel> createField(FieldModel field);
  Future<FieldModel> updateField(FieldModel field);
  Future<void> deleteField(String fieldId);
  Future<List<FieldModel>> getFieldsByFarmId(String farmId);
}

/// ConnectRPC-based implementation of [FarmRemoteDataSource].
class FarmRemoteDataSourceImpl implements FarmRemoteDataSource {
  final ApiConfig _apiConfig;
  final http.Client _httpClient;
  final _log = Logger('FarmRemoteDataSource');

  FarmRemoteDataSourceImpl({
    required ApiConfig apiConfig,
    required http.Client httpClient,
  })  : _apiConfig = apiConfig,
        _httpClient = httpClient;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        ..._apiConfig.headers,
      };

  String _buildUrl(String service, String method) =>
      '${_apiConfig.origin}/yieldpoint.farm.v1.$service/$method';

  Future<Map<String, dynamic>> _post(
      String service, String method, Map<String, dynamic> body) async {
    final url = _buildUrl(service, method);
    _log.fine('POST $url');

    final response = await _httpClient
        .post(
          Uri.parse(url),
          headers: _headers,
          body: jsonEncode(body),
        )
        .timeout(_apiConfig.timeout);

    if (response.statusCode != 200) {
      _log.severe('RPC error ${response.statusCode}: ${response.body}');
      throw FarmRemoteException(
        'RPC call $service/$method failed',
        statusCode: response.statusCode,
        body: response.body,
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  @override
  Future<List<FarmModel>> getFarms(String userId) async {
    final data = await _post('FarmService', 'ListFarms', {
      'owner_id': userId,
    });
    final farms = data['farms'] as List<dynamic>? ?? [];
    return farms
        .map((f) => FarmModel.fromProto(f as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<FarmModel> getFarmById(String farmId) async {
    final data = await _post('FarmService', 'GetFarm', {
      'id': farmId,
    });
    return FarmModel.fromProto(data['farm'] as Map<String, dynamic>);
  }

  @override
  Future<FarmModel> createFarm(FarmModel farm) async {
    final data = await _post('FarmService', 'CreateFarm', {
      'farm': farm.toProto(),
    });
    return FarmModel.fromProto(data['farm'] as Map<String, dynamic>);
  }

  @override
  Future<FarmModel> updateFarm(FarmModel farm) async {
    final data = await _post('FarmService', 'UpdateFarm', {
      'farm': farm.toProto(),
    });
    return FarmModel.fromProto(data['farm'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteFarm(String farmId) async {
    await _post('FarmService', 'DeleteFarm', {
      'id': farmId,
    });
  }

  @override
  Future<FieldModel> createField(FieldModel field) async {
    final data = await _post('FieldService', 'CreateField', {
      'field': field.toProto(),
    });
    return FieldModel.fromProto(data['field'] as Map<String, dynamic>);
  }

  @override
  Future<FieldModel> updateField(FieldModel field) async {
    final data = await _post('FieldService', 'UpdateField', {
      'field': field.toProto(),
    });
    return FieldModel.fromProto(data['field'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteField(String fieldId) async {
    await _post('FieldService', 'DeleteField', {
      'id': fieldId,
    });
  }

  @override
  Future<List<FieldModel>> getFieldsByFarmId(String farmId) async {
    final data = await _post('FieldService', 'ListFields', {
      'farm_id': farmId,
    });
    final fields = data['fields'] as List<dynamic>? ?? [];
    return fields
        .map((f) => FieldModel.fromProto(f as Map<String, dynamic>))
        .toList();
  }
}

/// Exception thrown when a remote farm API call fails.
class FarmRemoteException implements Exception {
  final String message;
  final int? statusCode;
  final String? body;

  const FarmRemoteException(this.message, {this.statusCode, this.body});

  @override
  String toString() =>
      'FarmRemoteException($message, statusCode: $statusCode)';
}
