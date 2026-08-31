import 'dart:convert';

import 'package:flutter_network/flutter_network.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import '../../domain/entities/satellite_entity.dart';
import '../models/ndvi_data_model.dart';
import '../models/satellite_tile_model.dart';

/// Remote data source for satellite monitoring using ConnectRPC.
abstract class SatelliteRemoteDataSource {
  Future<List<SatelliteTileModel>> getSatelliteTiles({
    required String fieldId,
    SatelliteLayerType? layerType,
    DateTime? from,
    DateTime? to,
  });

  Future<List<NdviDataModel>> getNdviHistory({
    required String fieldId,
    required DateTime from,
    required DateTime to,
  });

  Future<Map<String, dynamic>> getCropHealth({required String fieldId});
  Future<List<Map<String, dynamic>>> getCropHealthByFarm({
    required String farmId,
  });
}

/// ConnectRPC-based implementation of [SatelliteRemoteDataSource].
class SatelliteRemoteDataSourceImpl implements SatelliteRemoteDataSource {
  final ApiConfig _apiConfig;
  final http.Client _httpClient;
  final _log = Logger('SatelliteRemoteDataSource');

  SatelliteRemoteDataSourceImpl({
    required ApiConfig apiConfig,
    required http.Client httpClient,
  })  : _apiConfig = apiConfig,
        _httpClient = httpClient;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        ..._apiConfig.headers,
      };

  String _buildUrl(String service, String method) =>
      '${_apiConfig.origin}/yieldpoint.satellite.v1.$service/$method';

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
      throw SatelliteRemoteException(
        'RPC call $service/$method failed',
        statusCode: response.statusCode,
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  @override
  Future<List<SatelliteTileModel>> getSatelliteTiles({
    required String fieldId,
    SatelliteLayerType? layerType,
    DateTime? from,
    DateTime? to,
  }) async {
    final body = <String, dynamic>{
      'field_id': fieldId,
      if (layerType != null) 'layer_type': layerType.name,
      if (from != null) 'from': from.millisecondsSinceEpoch,
      if (to != null) 'to': to.millisecondsSinceEpoch,
    };
    final data = await _post('SatelliteService', 'ListTiles', body);
    final tiles = data['tiles'] as List<dynamic>? ?? [];
    return tiles
        .map((t) => SatelliteTileModel.fromProto(t as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<NdviDataModel>> getNdviHistory({
    required String fieldId,
    required DateTime from,
    required DateTime to,
  }) async {
    final data = await _post('SatelliteService', 'GetNdviHistory', {
      'field_id': fieldId,
      'from': from.millisecondsSinceEpoch,
      'to': to.millisecondsSinceEpoch,
    });
    final points = data['data_points'] as List<dynamic>? ?? [];
    return points
        .map((p) => NdviDataModel.fromProto(p as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Map<String, dynamic>> getCropHealth({required String fieldId}) async {
    final data = await _post('SatelliteService', 'GetCropHealth', {
      'field_id': fieldId,
    });
    return data['crop_health'] as Map<String, dynamic>;
  }

  @override
  Future<List<Map<String, dynamic>>> getCropHealthByFarm({
    required String farmId,
  }) async {
    final data = await _post('SatelliteService', 'GetCropHealthByFarm', {
      'farm_id': farmId,
    });
    final items = data['crop_health_list'] as List<dynamic>? ?? [];
    return items.cast<Map<String, dynamic>>();
  }
}

/// Exception thrown when a satellite remote API call fails.
class SatelliteRemoteException implements Exception {
  final String message;
  final int? statusCode;

  const SatelliteRemoteException(this.message, {this.statusCode});

  @override
  String toString() =>
      'SatelliteRemoteException($message, statusCode: $statusCode)';
}
