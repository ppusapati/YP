import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_network/flutter_network.dart';

import '../models/yield_prediction_model.dart';

abstract class YieldAnalysisRemoteDataSource {
  Future<List<YieldPredictionModel>> getYieldForecast(String fieldId);
  Future<List<YieldPredictionModel>> getYieldHistory(String fieldId);
}

class YieldAnalysisRemoteDataSourceImpl implements YieldAnalysisRemoteDataSource {
  final ConnectClient _client;
  YieldAnalysisRemoteDataSourceImpl(this._client);

  Future<Map<String, dynamic>> _post(String method, Map<String, dynamic> body) async {
    final response = await _client.unary(
      '/yieldpoint.agronomy.v1.YieldService/$method',
      body: Uint8List.fromList(utf8.encode(jsonEncode(body))),
      headers: {'Content-Type': 'application/json'},
    );
    if (!response.isSuccess) throw Exception('YieldService/$method failed');
    return jsonDecode(utf8.decode(response.body)) as Map<String, dynamic>;
  }

  @override
  Future<List<YieldPredictionModel>> getYieldForecast(String fieldId) async {
    final data = await _post('GetForecast', {'field_id': fieldId});
    final list = data['predictions'] as List<dynamic>? ?? [];
    return list.map((e) => YieldPredictionModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<YieldPredictionModel>> getYieldHistory(String fieldId) async {
    final data = await _post('GetHistory', {'field_id': fieldId});
    final list = data['predictions'] as List<dynamic>? ?? [];
    return list.map((e) => YieldPredictionModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
