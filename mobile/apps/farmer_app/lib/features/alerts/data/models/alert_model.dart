import '../../domain/entities/alert_entity.dart';

class AlertModel extends Alert {
  const AlertModel({
    required super.id,
    required super.type,
    required super.title,
    required super.message,
    required super.severity,
    super.status,
    required super.farmId,
    super.fieldId,
    super.fieldName,
    required super.timestamp,
    super.read,
    super.actionUrl,
    super.recommendations,
    super.acknowledgedAt,
    super.acknowledgedBy,
    super.metrics,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'] as String,
      type: AlertType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AlertType.cropStress,
      ),
      title: json['title'] as String,
      message: json['message'] as String,
      severity: AlertSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => AlertSeverity.info,
      ),
      status: AlertStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AlertStatus.active,
      ),
      farmId: json['farm_id'] as String,
      fieldId: json['field_id'] as String?,
      fieldName: json['field_name'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      read: json['read'] as bool? ?? false,
      actionUrl: json['action_url'] as String?,
      recommendations: (json['recommendations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      acknowledgedAt: json['acknowledged_at'] != null
          ? DateTime.parse(json['acknowledged_at'] as String)
          : null,
      acknowledgedBy: json['acknowledged_by'] as String?,
      metrics: json['metrics'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'message': message,
      'severity': severity.name,
      'status': status.name,
      'farm_id': farmId,
      'field_id': fieldId,
      'field_name': fieldName,
      'timestamp': timestamp.toIso8601String(),
      'read': read,
      'action_url': actionUrl,
      'recommendations': recommendations,
      if (acknowledgedAt != null)
        'acknowledged_at': acknowledgedAt!.toIso8601String(),
      if (acknowledgedBy != null) 'acknowledged_by': acknowledgedBy,
      if (metrics != null) 'metrics': metrics,
    };
  }

  factory AlertModel.fromEntity(Alert alert) {
    return AlertModel(
      id: alert.id,
      type: alert.type,
      title: alert.title,
      message: alert.message,
      severity: alert.severity,
      status: alert.status,
      farmId: alert.farmId,
      fieldId: alert.fieldId,
      fieldName: alert.fieldName,
      timestamp: alert.timestamp,
      read: alert.read,
      actionUrl: alert.actionUrl,
      recommendations: alert.recommendations,
      acknowledgedAt: alert.acknowledgedAt,
      acknowledgedBy: alert.acknowledgedBy,
      metrics: alert.metrics,
    );
  }
}

/// Data model for [AlertRule] with JSON serialization.
class AlertRuleModel {
  final String id;
  final String fieldId;
  final String fieldName;
  final String alertType;
  final bool enabled;
  final double? threshold;
  final String minimumSeverity;
  final bool pushEnabled;
  final bool emailEnabled;
  final bool smsEnabled;

  const AlertRuleModel({
    required this.id,
    required this.fieldId,
    required this.fieldName,
    required this.alertType,
    this.enabled = true,
    this.threshold,
    this.minimumSeverity = 'warning',
    this.pushEnabled = true,
    this.emailEnabled = false,
    this.smsEnabled = false,
  });

  factory AlertRuleModel.fromJson(Map<String, dynamic> json) {
    return AlertRuleModel(
      id: json['id'] as String,
      fieldId: json['field_id'] as String,
      fieldName: json['field_name'] as String,
      alertType: json['alert_type'] as String,
      enabled: json['enabled'] as bool? ?? true,
      threshold: (json['threshold'] as num?)?.toDouble(),
      minimumSeverity: json['minimum_severity'] as String? ?? 'warning',
      pushEnabled: json['push_enabled'] as bool? ?? true,
      emailEnabled: json['email_enabled'] as bool? ?? false,
      smsEnabled: json['sms_enabled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'field_id': fieldId,
      'field_name': fieldName,
      'alert_type': alertType,
      'enabled': enabled,
      if (threshold != null) 'threshold': threshold,
      'minimum_severity': minimumSeverity,
      'push_enabled': pushEnabled,
      'email_enabled': emailEnabled,
      'sms_enabled': smsEnabled,
    };
  }

  AlertRule toEntity() {
    return AlertRule(
      id: id,
      fieldId: fieldId,
      fieldName: fieldName,
      alertType: AlertType.values.firstWhere(
        (e) => e.name == alertType,
        orElse: () => AlertType.cropStress,
      ),
      enabled: enabled,
      threshold: threshold,
      minimumSeverity: AlertSeverity.values.firstWhere(
        (e) => e.name == minimumSeverity,
        orElse: () => AlertSeverity.warning,
      ),
      pushEnabled: pushEnabled,
      emailEnabled: emailEnabled,
      smsEnabled: smsEnabled,
    );
  }

  factory AlertRuleModel.fromEntity(AlertRule entity) {
    return AlertRuleModel(
      id: entity.id,
      fieldId: entity.fieldId,
      fieldName: entity.fieldName,
      alertType: entity.alertType.name,
      enabled: entity.enabled,
      threshold: entity.threshold,
      minimumSeverity: entity.minimumSeverity.name,
      pushEnabled: entity.pushEnabled,
      emailEnabled: entity.emailEnabled,
      smsEnabled: entity.smsEnabled,
    );
  }
}

/// Data model for [FieldRiskScore] with JSON serialization.
class FieldRiskScoreModel {
  final String fieldId;
  final String fieldName;
  final double overallScore;
  final Map<String, double> riskFactors;
  final DateTime calculatedAt;
  final String? trend;

  const FieldRiskScoreModel({
    required this.fieldId,
    required this.fieldName,
    required this.overallScore,
    this.riskFactors = const {},
    required this.calculatedAt,
    this.trend,
  });

  factory FieldRiskScoreModel.fromJson(Map<String, dynamic> json) {
    return FieldRiskScoreModel(
      fieldId: json['field_id'] as String,
      fieldName: json['field_name'] as String,
      overallScore: (json['overall_score'] as num).toDouble(),
      riskFactors: (json['risk_factors'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as num).toDouble()),
          ) ??
          const {},
      calculatedAt: DateTime.parse(json['calculated_at'] as String),
      trend: json['trend'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'field_id': fieldId,
      'field_name': fieldName,
      'overall_score': overallScore,
      'risk_factors': riskFactors,
      'calculated_at': calculatedAt.toIso8601String(),
      if (trend != null) 'trend': trend,
    };
  }

  FieldRiskScore toEntity() {
    return FieldRiskScore(
      fieldId: fieldId,
      fieldName: fieldName,
      overallScore: overallScore,
      riskFactors: riskFactors,
      calculatedAt: calculatedAt,
      trend: trend,
    );
  }

  factory FieldRiskScoreModel.fromEntity(FieldRiskScore entity) {
    return FieldRiskScoreModel(
      fieldId: entity.fieldId,
      fieldName: entity.fieldName,
      overallScore: entity.overallScore,
      riskFactors: entity.riskFactors,
      calculatedAt: entity.calculatedAt,
      trend: entity.trend,
    );
  }
}
