import 'dart:convert';

import 'package:http/http.dart' as http;

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
  YieldRemoteDataSourceImpl({
    required http.Client client,
    required String baseUrl,
  })  : _client = client,
        _baseUrl = baseUrl;

  final http.Client _client;
  final String _baseUrl;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  @override
  Future<List<YieldPredictionModel>> getPredictions({
    String? fieldId,
    String? cropType,
  }) async {
    final queryParams = <String, String>{};
    if (fieldId != null) queryParams['field_id'] = fieldId;
    if (cropType != null) queryParams['crop_type'] = cropType;

    final uri = Uri.parse('$_baseUrl/api/v1/yield/predictions')
        .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    final response = await _client.get(uri, headers: _headers);
    _handleError(response);
    final List<dynamic> data = json.decode(response.body)['data'];
    return data
        .map((e) =>
            YieldPredictionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<YieldPredictionModel> getPredictionById(String predictionId) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/api/v1/yield/predictions/$predictionId'),
      headers: _headers,
    );
    _handleError(response);
    final data = json.decode(response.body)['data'] as Map<String, dynamic>;
    return YieldPredictionModel.fromJson(data);
  }

  @override
  Future<List<YieldPredictionModel>> getHistory(
    String fieldId, {
    String? cropType,
  }) async {
    final queryParams = <String, String>{};
    if (cropType != null) queryParams['crop_type'] = cropType;

    final uri =
        Uri.parse('$_baseUrl/api/v1/yield/fields/$fieldId/history')
            .replace(
                queryParameters:
                    queryParams.isNotEmpty ? queryParams : null);

    final response = await _client.get(uri, headers: _headers);
    _handleError(response);
    final List<dynamic> data = json.decode(response.body)['data'];
    return data
        .map((e) =>
            YieldPredictionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  void _handleError(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw YieldRemoteException(
        statusCode: response.statusCode,
        message: _extractErrorMessage(response.body),
      );
    }
  }

  String _extractErrorMessage(String body) {
    try {
      return (json.decode(body)['message'] as String?) ?? 'Unknown error';
    } catch (_) {
      return 'Server error';
    }
  }
}

class YieldRemoteException implements Exception {
  const YieldRemoteException({
    required this.statusCode,
    required this.message,
  });

  final int statusCode;
  final String message;

  @override
  String toString() => 'YieldRemoteException($statusCode): $message';
}
