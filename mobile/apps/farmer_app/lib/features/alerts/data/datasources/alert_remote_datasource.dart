import 'dart:convert';

import 'package:flutter_network/flutter_network.dart';

import '../models/alert_model.dart';

abstract class AlertRemoteDataSource {
  Future<List<AlertModel>> getAlerts({String? farmId, String? severity});
  Future<AlertModel> getAlertById(String alertId);
  Future<void> markAlertRead(String alertId);
  Future<void> markAllAlertsRead({String? farmId});
  Future<int> getUnreadCount({String? farmId});
}

class AlertRemoteDataSourceImpl implements AlertRemoteDataSource {
  const AlertRemoteDataSourceImpl(this._client);

  final ConnectClient _client;

  static const _basePath = '/yieldpoint.alert.v1.AlertService';

  @override
  Future<List<AlertModel>> getAlerts({String? farmId, String? severity}) async {
    final body = <String, dynamic>{};
    if (farmId != null) body['farm_id'] = farmId;
    if (severity != null) body['severity'] = severity;

    final response = await _client.unary(
      '$_basePath/ListAlerts',
      body: utf8.encoder.convert(jsonEncode(body)),
      headers: {'Content-Type': 'application/json'},
    );

    if (!response.isSuccess) {
      throw const ConnectException(
        code: 'internal',
        message: 'Failed to fetch alerts',
      );
    }

    final data = jsonDecode(utf8.decode(response.body)) as Map<String, dynamic>;
    final alertsList = data['alerts'] as List<dynamic>? ?? [];
    return alertsList
        .map((e) => AlertModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<AlertModel> getAlertById(String alertId) async {
    final body = jsonEncode({'alert_id': alertId});

    final response = await _client.unary(
      '$_basePath/GetAlert',
      body: utf8.encoder.convert(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (!response.isSuccess) {
      throw const ConnectException(
        code: 'not_found',
        message: 'Alert not found',
      );
    }

    final data = jsonDecode(utf8.decode(response.body)) as Map<String, dynamic>;
    return AlertModel.fromJson(data);
  }

  @override
  Future<void> markAlertRead(String alertId) async {
    final body = jsonEncode({'alert_id': alertId});

    final response = await _client.unary(
      '$_basePath/MarkAlertRead',
      body: utf8.encoder.convert(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (!response.isSuccess) {
      throw const ConnectException(
        code: 'internal',
        message: 'Failed to mark alert as read',
      );
    }
  }

  @override
  Future<void> markAllAlertsRead({String? farmId}) async {
    final body = <String, dynamic>{};
    if (farmId != null) body['farm_id'] = farmId;

    final response = await _client.unary(
      '$_basePath/MarkAllAlertsRead',
      body: utf8.encoder.convert(jsonEncode(body)),
      headers: {'Content-Type': 'application/json'},
    );

    if (!response.isSuccess) {
      throw const ConnectException(
        code: 'internal',
        message: 'Failed to mark all alerts as read',
      );
    }
  }

  @override
  Future<int> getUnreadCount({String? farmId}) async {
    final body = <String, dynamic>{};
    if (farmId != null) body['farm_id'] = farmId;

    final response = await _client.unary(
      '$_basePath/GetUnreadCount',
      body: utf8.encoder.convert(jsonEncode(body)),
      headers: {'Content-Type': 'application/json'},
    );

    if (!response.isSuccess) {
      throw const ConnectException(
        code: 'internal',
        message: 'Failed to get unread count',
      );
    }

    final data = jsonDecode(utf8.decode(response.body)) as Map<String, dynamic>;
    return data['count'] as int? ?? 0;
  }
}
