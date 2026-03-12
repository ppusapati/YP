import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/sensor_model.dart';
import '../models/sensor_reading_model.dart';

abstract class SensorRemoteDataSource {
  Future<List<SensorModel>> getSensors();
  Future<List<SensorModel>> getSensorsByType(String type);
  Future<SensorModel> getSensorById(String sensorId);
  Future<List<SensorReadingModel>> getSensorReadings(
    String sensorId, {
    DateTime? from,
    DateTime? to,
  });
  Future<Map<String, SensorModel>> getSensorDashboard();
  Future<void> refreshSensor(String sensorId);
}

class SensorRemoteDataSourceImpl implements SensorRemoteDataSource {
  SensorRemoteDataSourceImpl({
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
  Future<List<SensorModel>> getSensors() async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/api/v1/sensors'),
      headers: _headers,
    );
    _handleError(response);
    final List<dynamic> data = json.decode(response.body)['data'];
    return data
        .map((e) => SensorModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<SensorModel>> getSensorsByType(String type) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/api/v1/sensors?type=$type'),
      headers: _headers,
    );
    _handleError(response);
    final List<dynamic> data = json.decode(response.body)['data'];
    return data
        .map((e) => SensorModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<SensorModel> getSensorById(String sensorId) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/api/v1/sensors/$sensorId'),
      headers: _headers,
    );
    _handleError(response);
    final data = json.decode(response.body)['data'] as Map<String, dynamic>;
    return SensorModel.fromJson(data);
  }

  @override
  Future<List<SensorReadingModel>> getSensorReadings(
    String sensorId, {
    DateTime? from,
    DateTime? to,
  }) async {
    final queryParams = <String, String>{};
    if (from != null) queryParams['from'] = from.toIso8601String();
    if (to != null) queryParams['to'] = to.toIso8601String();

    final uri = Uri.parse('$_baseUrl/api/v1/sensors/$sensorId/readings')
        .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    final response = await _client.get(uri, headers: _headers);
    _handleError(response);
    final List<dynamic> data = json.decode(response.body)['data'];
    return data
        .map((e) => SensorReadingModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Map<String, SensorModel>> getSensorDashboard() async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/api/v1/sensors/dashboard'),
      headers: _headers,
    );
    _handleError(response);
    final Map<String, dynamic> data = json.decode(response.body)['data'];
    return data.map(
      (key, value) =>
          MapEntry(key, SensorModel.fromJson(value as Map<String, dynamic>)),
    );
  }

  @override
  Future<void> refreshSensor(String sensorId) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/api/v1/sensors/$sensorId/refresh'),
      headers: _headers,
    );
    _handleError(response);
  }

  void _handleError(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw SensorRemoteException(
        statusCode: response.statusCode,
        message: _extractErrorMessage(response.body),
      );
    }
  }

  String _extractErrorMessage(String body) {
    try {
      final decoded = json.decode(body);
      return decoded['message'] as String? ?? 'Unknown error';
    } catch (_) {
      return 'Server error';
    }
  }
}

class SensorRemoteException implements Exception {
  const SensorRemoteException({
    required this.statusCode,
    required this.message,
  });

  final int statusCode;
  final String message;

  @override
  String toString() => 'SensorRemoteException($statusCode): $message';
}
