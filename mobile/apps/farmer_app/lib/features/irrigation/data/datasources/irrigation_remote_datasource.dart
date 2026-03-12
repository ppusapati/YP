import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/irrigation_schedule_model.dart';
import '../models/irrigation_zone_model.dart';

abstract class IrrigationRemoteDataSource {
  Future<List<IrrigationZoneModel>> getZones(String fieldId);
  Future<IrrigationZoneModel> getZoneById(String zoneId);
  Future<List<IrrigationScheduleModel>> getSchedules(String zoneId);
  Future<IrrigationScheduleModel> updateSchedule(
      IrrigationScheduleModel schedule);
  Future<void> deleteSchedule(String scheduleId);
  Future<List<Map<String, dynamic>>> getAlerts({String? zoneId});
}

class IrrigationRemoteDataSourceImpl implements IrrigationRemoteDataSource {
  IrrigationRemoteDataSourceImpl({
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
  Future<List<IrrigationZoneModel>> getZones(String fieldId) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/api/v1/irrigation/zones?field_id=$fieldId'),
      headers: _headers,
    );
    _handleError(response);
    final List<dynamic> data = json.decode(response.body)['data'];
    return data
        .map((e) => IrrigationZoneModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<IrrigationZoneModel> getZoneById(String zoneId) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/api/v1/irrigation/zones/$zoneId'),
      headers: _headers,
    );
    _handleError(response);
    final data = json.decode(response.body)['data'] as Map<String, dynamic>;
    return IrrigationZoneModel.fromJson(data);
  }

  @override
  Future<List<IrrigationScheduleModel>> getSchedules(String zoneId) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/api/v1/irrigation/zones/$zoneId/schedules'),
      headers: _headers,
    );
    _handleError(response);
    final List<dynamic> data = json.decode(response.body)['data'];
    return data
        .map(
            (e) => IrrigationScheduleModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<IrrigationScheduleModel> updateSchedule(
      IrrigationScheduleModel schedule) async {
    final response = await _client.put(
      Uri.parse('$_baseUrl/api/v1/irrigation/schedules/${schedule.id}'),
      headers: _headers,
      body: json.encode(schedule.toJson()),
    );
    _handleError(response);
    final data = json.decode(response.body)['data'] as Map<String, dynamic>;
    return IrrigationScheduleModel.fromJson(data);
  }

  @override
  Future<void> deleteSchedule(String scheduleId) async {
    final response = await _client.delete(
      Uri.parse('$_baseUrl/api/v1/irrigation/schedules/$scheduleId'),
      headers: _headers,
    );
    _handleError(response);
  }

  @override
  Future<List<Map<String, dynamic>>> getAlerts({String? zoneId}) async {
    final queryParam = zoneId != null ? '?zone_id=$zoneId' : '';
    final response = await _client.get(
      Uri.parse('$_baseUrl/api/v1/irrigation/alerts$queryParam'),
      headers: _headers,
    );
    _handleError(response);
    final List<dynamic> data = json.decode(response.body)['data'];
    return data.cast<Map<String, dynamic>>();
  }

  void _handleError(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw IrrigationRemoteException(
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

class IrrigationRemoteException implements Exception {
  const IrrigationRemoteException({
    required this.statusCode,
    required this.message,
  });

  final int statusCode;
  final String message;

  @override
  String toString() => 'IrrigationRemoteException($statusCode): $message';
}
