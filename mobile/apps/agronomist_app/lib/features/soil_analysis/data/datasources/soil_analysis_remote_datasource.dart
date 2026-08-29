import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_network/flutter_network.dart';
import 'package:logging/logging.dart';

import '../models/soil_analysis_model.dart';

abstract class SoilAnalysisRemoteDataSource {
  Future<List<SoilAnalysisModel>> getSoilAnalyses(String fieldId);
  Future<SoilAnalysisModel> createSoilAnalysis(SoilAnalysisModel analysis);
}

class SoilAnalysisRemoteDataSourceImpl implements SoilAnalysisRemoteDataSource {
  final ConnectClient _client;
  final _log = Logger('SoilAnalysisRemoteDataSource');

  SoilAnalysisRemoteDataSourceImpl(this._client);

  Future<Map<String, dynamic>> _post(
      String method, Map<String, dynamic> body) async {
    final path = '/yieldpoint.agronomy.v1.SoilService/$method';
    _log.fine('POST $path');

    final response = await _client.unary(
      path,
      body: Uint8List.fromList(utf8.encode(jsonEncode(body))),
      headers: {'Content-Type': 'application/json'},
    );

    if (!response.isSuccess) {
      throw Exception('RPC call SoilService/$method failed');
    }

    return jsonDecode(utf8.decode(response.body)) as Map<String, dynamic>;
  }

  @override
  Future<List<SoilAnalysisModel>> getSoilAnalyses(String fieldId) async {
    final data = await _post('ListSoilAnalyses', {'field_id': fieldId});
    final list = data['analyses'] as List<dynamic>? ?? [];
    return list
        .map((e) => SoilAnalysisModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<SoilAnalysisModel> createSoilAnalysis(
      SoilAnalysisModel analysis) async {
    final data = await _post('CreateSoilAnalysis', {
      'analysis': analysis.toJson(),
    });
    return SoilAnalysisModel.fromJson(
        data['analysis'] as Map<String, dynamic>);
  }
}
