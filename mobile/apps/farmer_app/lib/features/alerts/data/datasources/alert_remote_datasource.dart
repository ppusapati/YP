import 'dart:convert';

import 'package:flutter_network/flutter_network.dart';

import '../models/alert_model.dart';

abstract class AlertRemoteDataSource {
  Future<List<AlertModel>> getAlerts({String? farmId, String? severity});
  Future<AlertModel> getAlertById(String alertId);
  Future<void> markAlertRead(String alertId);
  Future<void> markAllAlertsRead({String? farmId});
  Future<int> getUnreadCount({String? farmId});
  Future<AlertModel> acknowledgeAlert(String alertId);
  Future<FieldRiskScoreModel> getFieldRisk(String fieldId);
  Future<List<AlertRuleModel>> getAlertRules({String? fieldId});
  Future<AlertRuleModel> updateAlertRule(AlertRuleModel rule);
}

class AlertRemoteDataSourceImpl implements AlertRemoteDataSource {
  const AlertRemoteDataSourceImpl(this._client);

  final ConnectClient _client;

  static const _basePath = '/agriculture.alert.v1.AlertService';

  Future<Map<String, dynamic>> _post(
      String method, Map<String, dynamic> body) async {
    final response = await _client.unary(
      '$_basePath/$method',
      body: utf8.encoder.convert(jsonEncode(body)),
      headers: {'Content-Type': 'application/json'},
    );

    if (!response.isSuccess) {
      throw ConnectException(
        code: 'internal',
        message: 'AlertService/$method failed',
      );
    }

    return jsonDecode(utf8.decode(response.body)) as Map<String, dynamic>;
  }

  @override
  Future<List<AlertModel>> getAlerts({String? farmId, String? severity}) async {
    final body = <String, dynamic>{};
    if (farmId != null) body['farm_id'] = farmId;
    if (severity != null) body['severity'] = severity;

    final data = await _post('ListAlerts', body);
    final alertsList = data['alerts'] as List<dynamic>? ?? [];
    return alertsList
        .map((e) => AlertModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<AlertModel> getAlertById(String alertId) async {
    final data = await _post('GetAlert', {'alert_id': alertId});
    return AlertModel.fromJson(data['alert'] as Map<String, dynamic>? ?? data);
  }

  @override
  Future<void> markAlertRead(String alertId) async {
    await _post('MarkAlertRead', {'alert_id': alertId});
  }

  @override
  Future<void> markAllAlertsRead({String? farmId}) async {
    final body = <String, dynamic>{};
    if (farmId != null) body['farm_id'] = farmId;
    await _post('MarkAllAlertsRead', body);
  }

  @override
  Future<int> getUnreadCount({String? farmId}) async {
    final body = <String, dynamic>{};
    if (farmId != null) body['farm_id'] = farmId;
    final data = await _post('GetUnreadCount', body);
    return data['count'] as int? ?? 0;
  }

  @override
  Future<AlertModel> acknowledgeAlert(String alertId) async {
    final data = await _post('AcknowledgeAlert', {'alert_id': alertId});
    return AlertModel.fromJson(data['alert'] as Map<String, dynamic>? ?? data);
  }

  @override
  Future<FieldRiskScoreModel> getFieldRisk(String fieldId) async {
    final data = await _post('GetFieldRisk', {'field_id': fieldId});
    return FieldRiskScoreModel.fromJson(
        data['risk_score'] as Map<String, dynamic>? ?? data);
  }

  @override
  Future<List<AlertRuleModel>> getAlertRules({String? fieldId}) async {
    final body = <String, dynamic>{};
    if (fieldId != null) body['field_id'] = fieldId;
    final data = await _post('ListAlertRules', body);
    final rulesList = data['rules'] as List<dynamic>? ?? [];
    return rulesList
        .map((e) => AlertRuleModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<AlertRuleModel> updateAlertRule(AlertRuleModel rule) async {
    final data = await _post('UpdateAlertRule', {'rule': rule.toJson()});
    return AlertRuleModel.fromJson(
        data['rule'] as Map<String, dynamic>? ?? data);
  }
}
