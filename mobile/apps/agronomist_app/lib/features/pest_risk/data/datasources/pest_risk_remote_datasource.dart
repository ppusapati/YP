import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_network/flutter_network.dart';
import 'package:logging/logging.dart';

import '../models/pest_risk_model.dart';

abstract class PestRiskRemoteDataSource {
  Future<List<PestRiskModel>> getPestRisks(String fieldId);
  Future<List<PestRiskModel>> getPestAlerts();
}

class PestRiskRemoteDataSourceImpl implements PestRiskRemoteDataSource {
  final ConnectClient _client;
  final _log = Logger('PestRiskRemoteDataSource');

  PestRiskRemoteDataSourceImpl(this._client);

  Future<Map<String, dynamic>> _post(
      String method, Map<String, dynamic> body) async {
    final path = '/yieldpoint.agronomy.v1.PestRiskService/$method';
    _log.fine('POST $path');
    final response = await _client.unary(
      path,
      body: Uint8List.fromList(utf8.encode(jsonEncode(body))),
      headers: {'Content-Type': 'application/json'},
    );
    if (!response.isSuccess) throw Exception('PestRiskService/$method failed');
    return jsonDecode(utf8.decode(response.body)) as Map<String, dynamic>;
  }

  @override
  Future<List<PestRiskModel>> getPestRisks(String fieldId) async {
    final data = await _post('PredictRisks', {'field_id': fieldId});
    final list = data['risks'] as List<dynamic>? ?? [];
    return list.map((e) => PestRiskModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<PestRiskModel>> getPestAlerts() async {
    final data = await _post('GetAlerts', {});
    final list = data['alerts'] as List<dynamic>? ?? [];
    return list.map((e) => PestRiskModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
