import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_network/flutter_network.dart';
import 'package:logging/logging.dart';

import '../models/satellite_data_model.dart';

abstract class SatelliteRemoteDataSource {
  Future<List<SatelliteDataModel>> getTilesForField(String fieldId);
  Future<List<StressAlertModel>> getStressAlerts(String farmId);
  Future<Map<String, dynamic>> getFieldSummary(String farmId, String fieldId);
}

class SatelliteRemoteDataSourceImpl implements SatelliteRemoteDataSource {
  final ConnectClient _client;
  final _log = Logger('SatelliteRemoteDataSource');

  SatelliteRemoteDataSourceImpl(this._client);

  Future<Map<String, dynamic>> _post(
      String method, Map<String, dynamic> body) async {
    final path = '/yieldpoint.agronomy.v1.SatelliteService/$method';
    _log.fine('POST $path');

    final response = await _client.unary(
      path,
      body: Uint8List.fromList(utf8.encode(jsonEncode(body))),
      headers: {'Content-Type': 'application/json'},
    );

    if (!response.isSuccess) {
      throw Exception('RPC call SatelliteService/$method failed');
    }

    return jsonDecode(utf8.decode(response.body)) as Map<String, dynamic>;
  }

  @override
  Future<List<SatelliteDataModel>> getTilesForField(String fieldId) async {
    final data = await _post('GetTiles', {'field_id': fieldId});
    final list = data['tiles'] as List<dynamic>? ?? [];
    return list
        .map((e) => SatelliteDataModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<StressAlertModel>> getStressAlerts(String farmId) async {
    final data = await _post('GetStressAlerts', {'farm_id': farmId});
    final list = data['alerts'] as List<dynamic>? ?? [];
    return list
        .map((e) => StressAlertModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Map<String, dynamic>> getFieldSummary(
      String farmId, String fieldId) async {
    return _post('GetFieldSummary', {
      'farm_id': farmId,
      'field_id': fieldId,
    });
  }
}
