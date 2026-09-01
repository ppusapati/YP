import 'package:flutter_network/flutter_network.dart';
import 'package:flutter_proto/src/generated/alert.pb.dart' as alert_pb;
import 'package:protobuf/protobuf.dart' as $pb;

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

  Future<ConnectResponse> _call(
      String method, $pb.GeneratedMessage request) async {
    final response = await _client.unary(
      '$_basePath/$method',
      body: request.writeToBuffer(),
    );
    if (!response.isSuccess) {
      throw ConnectException(
        code: 'internal',
        message: 'AlertService/$method failed',
        statusCode: response.statusCode,
      );
    }
    return response;
  }

  @override
  Future<List<AlertModel>> getAlerts(
      {String? farmId, String? severity}) async {
    final request = alert_pb.ListAlertsRequest(
      farmId: farmId,
    );
    // severity is a string in the interface but an enum in protobuf;
    // attempt to match by name if provided.
    if (severity != null) {
      final match = alert_pb.AlertSeverity.values.cast<alert_pb.AlertSeverity?>().firstWhere(
        (alert_pb.AlertSeverity? v) => v!.name.toLowerCase().contains(severity.toLowerCase()),
        orElse: () => null,
      );
      if (match != null) {
        request.severity = match;
      }
    }

    final response = await _call('ListAlerts', request);
    final pbResponse =
        alert_pb.ListAlertsResponse.fromBuffer(response.body);
    return pbResponse.alerts.map(_alertFromPb).toList();
  }

  @override
  Future<AlertModel> getAlertById(String alertId) async {
    final request = alert_pb.GetAlertRequest(id: alertId);
    final response = await _call('GetAlert', request);
    final pbResponse = alert_pb.GetAlertResponse.fromBuffer(response.body);
    return _alertFromPb(pbResponse.alert);
  }

  @override
  Future<void> markAlertRead(String alertId) async {
    final request = alert_pb.MarkAlertReadRequest(id: alertId);
    await _call('MarkAlertRead', request);
  }

  @override
  Future<void> markAllAlertsRead({String? farmId}) async {
    final request = alert_pb.MarkAllAlertsReadRequest(farmId: farmId);
    await _call('MarkAllAlertsRead', request);
  }

  @override
  Future<int> getUnreadCount({String? farmId}) async {
    final request = alert_pb.GetUnreadCountRequest(farmId: farmId);
    final response = await _call('GetUnreadCount', request);
    final pbResponse =
        alert_pb.GetUnreadCountResponse.fromBuffer(response.body);
    return pbResponse.count;
  }

  @override
  Future<AlertModel> acknowledgeAlert(String alertId) async {
    final request = alert_pb.AcknowledgeAlertRequest(id: alertId);
    final response = await _call('AcknowledgeAlert', request);
    final pbResponse =
        alert_pb.AcknowledgeAlertResponse.fromBuffer(response.body);
    return _alertFromPb(pbResponse.alert);
  }

  @override
  Future<FieldRiskScoreModel> getFieldRisk(String fieldId) async {
    final request = alert_pb.GetFieldRiskRequest(fieldId: fieldId);
    final response = await _call('GetFieldRisk', request);
    final pbResponse =
        alert_pb.GetFieldRiskResponse.fromBuffer(response.body);
    return _fieldRiskFromPb(pbResponse.riskScore);
  }

  @override
  Future<List<AlertRuleModel>> getAlertRules({String? fieldId}) async {
    final request = alert_pb.ListAlertRulesRequest(fieldId: fieldId);
    final response = await _call('ListAlertRules', request);
    final pbResponse =
        alert_pb.ListAlertRulesResponse.fromBuffer(response.body);
    return pbResponse.rules.map(_alertRuleFromPb).toList();
  }

  @override
  Future<AlertRuleModel> updateAlertRule(AlertRuleModel rule) async {
    final request = alert_pb.UpdateAlertRuleRequest(
      rule: _alertRuleToPb(rule),
    );
    final response = await _call('UpdateAlertRule', request);
    final pbResponse =
        alert_pb.UpdateAlertRuleResponse.fromBuffer(response.body);
    return _alertRuleFromPb(pbResponse.rule);
  }

  // ---------------------------------------------------------------------------
  // Pb-to-model helpers
  // ---------------------------------------------------------------------------

  static AlertModel _alertFromPb(alert_pb.Alert a) {
    return AlertModel(
      id: a.id,
      type: AlertType.values.firstWhere(
        (e) => e.name == a.type,
        orElse: () => AlertType.cropStress,
      ),
      title: a.title,
      message: a.message,
      severity: AlertSeverity.values.firstWhere(
        (e) => e.name.toLowerCase() == a.severity.name.toLowerCase() ||
            a.severity.name.toLowerCase().contains(e.name.toLowerCase()),
        orElse: () => AlertSeverity.info,
      ),
      status: AlertStatus.values.firstWhere(
        (e) => e.name.toLowerCase() == a.status.name.toLowerCase() ||
            a.status.name.toLowerCase().contains(e.name.toLowerCase()),
        orElse: () => AlertStatus.active,
      ),
      farmId: a.farmId,
      fieldId: a.hasFieldId() ? a.fieldId : null,
      fieldName: a.hasFieldName() ? a.fieldName : null,
      timestamp: a.hasTimestamp()
          ? DateTime.fromMillisecondsSinceEpoch(
              a.timestamp.seconds.toInt() * 1000 +
                  a.timestamp.nanos ~/ 1000000,
            )
          : DateTime.now(),
      read: a.read,
      actionUrl: a.hasActionUrl() ? a.actionUrl : null,
      recommendations: List<String>.from(a.recommendations),
      acknowledgedAt: a.hasAcknowledgedAt()
          ? DateTime.fromMillisecondsSinceEpoch(
              a.acknowledgedAt.seconds.toInt() * 1000 +
                  a.acknowledgedAt.nanos ~/ 1000000,
            )
          : null,
      acknowledgedBy: a.hasAcknowledgedBy() ? a.acknowledgedBy : null,
      metrics: a.metrics.isNotEmpty
          ? Map<String, dynamic>.from(a.metrics)
          : null,
    );
  }

  static FieldRiskScoreModel _fieldRiskFromPb(alert_pb.FieldRiskScore r) {
    return FieldRiskScoreModel(
      fieldId: r.fieldId,
      fieldName: r.fieldName,
      overallScore: r.overallScore,
      riskFactors: Map<String, double>.from(r.riskFactors),
      calculatedAt: r.hasCalculatedAt() && r.calculatedAt.isNotEmpty
          ? DateTime.parse(r.calculatedAt)
          : DateTime.now(),
      trend: r.hasTrend() ? r.trend : null,
    );
  }

  static AlertRuleModel _alertRuleFromPb(alert_pb.AlertRule r) {
    final channels = List<String>.from(r.notifyChannels);
    return AlertRuleModel(
      id: r.id,
      fieldId: r.fieldId,
      fieldName: '', // pb AlertRule has no fieldName
      alertType: r.metric,
      enabled: r.enabled,
      threshold: r.hasThreshold() ? r.threshold : null,
      minimumSeverity: r.severity.name,
      pushEnabled: channels.contains('push'),
      emailEnabled: channels.contains('email'),
      smsEnabled: channels.contains('sms'),
    );
  }

  static alert_pb.AlertRule _alertRuleToPb(AlertRuleModel rule) {
    final channels = <String>[
      if (rule.pushEnabled) 'push',
      if (rule.emailEnabled) 'email',
      if (rule.smsEnabled) 'sms',
    ];
    final pb = alert_pb.AlertRule(
      id: rule.id,
      fieldId: rule.fieldId,
      metric: rule.alertType,
      enabled: rule.enabled,
      notifyChannels: channels,
    );
    final threshold = rule.threshold;
    if (threshold != null) {
      pb.threshold = threshold;
    }
    return pb;
  }
}
