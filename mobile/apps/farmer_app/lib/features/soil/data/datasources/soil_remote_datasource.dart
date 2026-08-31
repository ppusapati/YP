import 'dart:convert';

import 'package:flutter_network/flutter_network.dart';

import '../models/soil_analysis_model.dart';

abstract class SoilRemoteDataSource {
  Future<SoilAnalysisModel> getSoilAnalysis(String fieldId);
  Future<List<SoilAnalysisModel>> getSoilHistory(
    String fieldId, {
    DateTime? from,
    DateTime? to,
  });
  Future<List<SoilAnalysisModel>> getAllFieldAnalyses();
}

class SoilRemoteDataSourceImpl implements SoilRemoteDataSource {
  const SoilRemoteDataSourceImpl(this._client);

  final ConnectClient _client;

  static const _basePath = '/yieldpoint.soil.v1.SoilService';

  @override
  Future<SoilAnalysisModel> getSoilAnalysis(String fieldId) async {
    final body = jsonEncode({'field_id': fieldId});

    final response = await _client.unary(
      '$_basePath/GetSoilAnalysis',
      body: utf8.encoder.convert(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (!response.isSuccess) {
      throw const ConnectException(
        code: 'not_found',
        message: 'Soil analysis not found',
      );
    }

    final data =
        jsonDecode(utf8.decode(response.body)) as Map<String, dynamic>;
    return SoilAnalysisModel.fromJson(data);
  }

  @override
  Future<List<SoilAnalysisModel>> getSoilHistory(
    String fieldId, {
    DateTime? from,
    DateTime? to,
  }) async {
    final reqBody = <String, dynamic>{'field_id': fieldId};
    if (from != null) reqBody['from'] = from.toIso8601String();
    if (to != null) reqBody['to'] = to.toIso8601String();

    final response = await _client.unary(
      '$_basePath/GetSoilHistory',
      body: utf8.encoder.convert(jsonEncode(reqBody)),
      headers: {'Content-Type': 'application/json'},
    );

    if (!response.isSuccess) {
      throw const ConnectException(
        code: 'internal',
        message: 'Failed to fetch soil history',
      );
    }

    final data =
        jsonDecode(utf8.decode(response.body)) as Map<String, dynamic>;
    final analyses = data['analyses'] as List<dynamic>? ?? [];
    return analyses
        .map((e) => SoilAnalysisModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<SoilAnalysisModel>> getAllFieldAnalyses() async {
    final response = await _client.unary(
      '$_basePath/ListFieldAnalyses',
      body: utf8.encoder.convert(jsonEncode(<String, dynamic>{})),
      headers: {'Content-Type': 'application/json'},
    );

    if (!response.isSuccess) {
      throw const ConnectException(
        code: 'internal',
        message: 'Failed to fetch field analyses',
      );
    }

    final data =
        jsonDecode(utf8.decode(response.body)) as Map<String, dynamic>;
    final analyses = data['analyses'] as List<dynamic>? ?? [];
    return analyses
        .map((e) => SoilAnalysisModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
