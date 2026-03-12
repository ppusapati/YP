import 'dart:convert';

import 'package:http/http.dart' as http;

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
  SoilRemoteDataSourceImpl({
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
  Future<SoilAnalysisModel> getSoilAnalysis(String fieldId) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/api/v1/soil/analysis/$fieldId'),
      headers: _headers,
    );
    _handleError(response);
    final data = json.decode(response.body)['data'] as Map<String, dynamic>;
    return SoilAnalysisModel.fromJson(data);
  }

  @override
  Future<List<SoilAnalysisModel>> getSoilHistory(
    String fieldId, {
    DateTime? from,
    DateTime? to,
  }) async {
    final queryParams = <String, String>{};
    if (from != null) queryParams['from'] = from.toIso8601String();
    if (to != null) queryParams['to'] = to.toIso8601String();

    final uri = Uri.parse('$_baseUrl/api/v1/soil/analysis/$fieldId/history')
        .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    final response = await _client.get(uri, headers: _headers);
    _handleError(response);
    final List<dynamic> data = json.decode(response.body)['data'];
    return data
        .map((e) => SoilAnalysisModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<SoilAnalysisModel>> getAllFieldAnalyses() async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/api/v1/soil/analysis'),
      headers: _headers,
    );
    _handleError(response);
    final List<dynamic> data = json.decode(response.body)['data'];
    return data
        .map((e) => SoilAnalysisModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  void _handleError(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw SoilRemoteException(
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

class SoilRemoteException implements Exception {
  const SoilRemoteException({
    required this.statusCode,
    required this.message,
  });

  final int statusCode;
  final String message;

  @override
  String toString() => 'SoilRemoteException($statusCode): $message';
}
