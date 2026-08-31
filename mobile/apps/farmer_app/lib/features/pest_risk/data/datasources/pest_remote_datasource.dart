import 'dart:convert';

import 'package:flutter_network/flutter_network.dart';
import 'package:logging/logging.dart';

import '../models/pest_risk_model.dart';

/// Remote data source for pest risk data, backed by ConnectRPC.
abstract class PestRemoteDataSource {
  Future<List<PestRiskZoneModel>> fetchPestRiskZones({String? fieldId});
  Future<List<PestAlertModel>> fetchPestAlerts({String? fieldId});
  Future<PestAlertModel> fetchPestAlertById(String alertId);
  Future<void> markAlertAsRead(String alertId);
}

class PestRemoteDataSourceImpl implements PestRemoteDataSource {
  PestRemoteDataSourceImpl({required ConnectClient client}) : _client = client;

  final ConnectClient _client;
  static final _log = Logger('PestRemoteDataSource');

  @override
  Future<List<PestRiskZoneModel>> fetchPestRiskZones({String? fieldId}) async {
    try {
      final path = '/yieldpoint.pest.v1.PestService/GetPestRiskZones';
      final body = fieldId != null
          ? utf8.encode(jsonEncode({'field_id': fieldId}))
          : null;

      final response = await _client.unary(
        path,
        body: body != null ? body as dynamic : null,
      );

      final data = jsonDecode(utf8.decode(response.body)) as Map<String, dynamic>;
      final zones = (data['zones'] as List<dynamic>?) ?? [];

      return zones
          .map((z) => PestRiskZoneModel.fromJson(z as Map<String, dynamic>))
          .toList();
    } on ConnectException catch (e) {
      _log.severe('Failed to fetch pest risk zones: $e');
      rethrow;
    }
  }

  @override
  Future<List<PestAlertModel>> fetchPestAlerts({String? fieldId}) async {
    try {
      final path = '/yieldpoint.pest.v1.PestService/GetPestAlerts';
      final body = fieldId != null
          ? utf8.encode(jsonEncode({'field_id': fieldId}))
          : null;

      final response = await _client.unary(
        path,
        body: body != null ? body as dynamic : null,
      );

      final data = jsonDecode(utf8.decode(response.body)) as Map<String, dynamic>;
      final alerts = (data['alerts'] as List<dynamic>?) ?? [];

      return alerts
          .map((a) => PestAlertModel.fromJson(a as Map<String, dynamic>))
          .toList();
    } on ConnectException catch (e) {
      _log.severe('Failed to fetch pest alerts: $e');
      rethrow;
    }
  }

  @override
  Future<PestAlertModel> fetchPestAlertById(String alertId) async {
    try {
      final path = '/yieldpoint.pest.v1.PestService/GetPestAlert';
      final body = utf8.encode(jsonEncode({'alert_id': alertId}));

      final response = await _client.unary(path, body: body as dynamic);

      final data = jsonDecode(utf8.decode(response.body)) as Map<String, dynamic>;
      return PestAlertModel.fromJson(data);
    } on ConnectException catch (e) {
      _log.severe('Failed to fetch pest alert $alertId: $e');
      rethrow;
    }
  }

  @override
  Future<void> markAlertAsRead(String alertId) async {
    try {
      final path = '/yieldpoint.pest.v1.PestService/MarkAlertAsRead';
      final body = utf8.encode(jsonEncode({'alert_id': alertId}));

      await _client.unary(path, body: body as dynamic);
    } on ConnectException catch (e) {
      _log.severe('Failed to mark alert $alertId as read: $e');
      rethrow;
    }
  }
}
