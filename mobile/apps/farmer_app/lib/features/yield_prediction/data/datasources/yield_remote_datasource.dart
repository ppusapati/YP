import 'dart:convert';

import 'package:flutter_network/flutter_network.dart';

import '../models/yield_prediction_model.dart';

abstract class YieldRemoteDataSource {
  Future<List<YieldPredictionModel>> getPredictions({
    String? fieldId,
    String? cropType,
  });
  Future<YieldPredictionModel> getPredictionById(String predictionId);
  Future<List<YieldPredictionModel>> getHistory(
    String fieldId, {
    String? cropType,
  });
}

class YieldRemoteDataSourceImpl implements YieldRemoteDataSource {
  const YieldRemoteDataSourceImpl(this._client);

  final ConnectClient _client;

  static const _basePath = '/yieldpoint.yield.v1.YieldService';

  @override
  Future<List<YieldPredictionModel>> getPredictions({
    String? fieldId,
    String? cropType,
  }) async {
    final reqBody = <String, dynamic>{};
    if (fieldId != null) reqBody['field_id'] = fieldId;
    if (cropType != null) reqBody['crop_type'] = cropType;

    final response = await _client.unary(
      '$_basePath/ListPredictions',
      body: utf8.encoder.convert(jsonEncode(reqBody)),
      headers: {'Content-Type': 'application/json'},
    );

    if (!response.isSuccess) {
      throw const ConnectException(
        code: 'internal',
        message: 'Failed to fetch yield predictions',
      );
    }

    final data =
        jsonDecode(utf8.decode(response.body)) as Map<String, dynamic>;
    final predictions = data['predictions'] as List<dynamic>? ?? [];
    return predictions
        .map((e) =>
            YieldPredictionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<YieldPredictionModel> getPredictionById(String predictionId) async {
    final body = jsonEncode({'prediction_id': predictionId});

    final response = await _client.unary(
      '$_basePath/GetPrediction',
      body: utf8.encoder.convert(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (!response.isSuccess) {
      throw const ConnectException(
        code: 'not_found',
        message: 'Yield prediction not found',
      );
    }

    final data =
        jsonDecode(utf8.decode(response.body)) as Map<String, dynamic>;
    return YieldPredictionModel.fromJson(data);
  }

  @override
  Future<List<YieldPredictionModel>> getHistory(
    String fieldId, {
    String? cropType,
  }) async {
    final reqBody = <String, dynamic>{'field_id': fieldId};
    if (cropType != null) reqBody['crop_type'] = cropType;

    final response = await _client.unary(
      '$_basePath/GetHistory',
      body: utf8.encoder.convert(jsonEncode(reqBody)),
      headers: {'Content-Type': 'application/json'},
    );

    if (!response.isSuccess) {
      throw const ConnectException(
        code: 'internal',
        message: 'Failed to fetch yield history',
      );
    }

    final data =
        jsonDecode(utf8.decode(response.body)) as Map<String, dynamic>;
    final predictions = data['predictions'] as List<dynamic>? ?? [];
    return predictions
        .map((e) =>
            YieldPredictionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
