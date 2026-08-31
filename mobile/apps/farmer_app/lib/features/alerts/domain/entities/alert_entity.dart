import 'package:equatable/equatable.dart';

/// The category of an alert.
enum AlertType {
  cropStress,
  waterShortage,
  diseaseOutbreak,
  pestOutbreak,
  irrigationNeeded,
  frostWarning,
  soilHealth,
  weatherEvent;

  String get displayName {
    switch (this) {
      case AlertType.cropStress:
        return 'Crop Stress';
      case AlertType.waterShortage:
        return 'Water Shortage';
      case AlertType.diseaseOutbreak:
        return 'Disease Outbreak';
      case AlertType.pestOutbreak:
        return 'Pest Outbreak';
      case AlertType.irrigationNeeded:
        return 'Irrigation Needed';
      case AlertType.frostWarning:
        return 'Frost Warning';
      case AlertType.soilHealth:
        return 'Soil Health';
      case AlertType.weatherEvent:
        return 'Weather Event';
    }
  }
}

/// The severity level of an alert.
enum AlertSeverity {
  info,
  warning,
  critical,
  emergency;

  String get displayName {
    switch (this) {
      case AlertSeverity.info:
        return 'Info';
      case AlertSeverity.warning:
        return 'Warning';
      case AlertSeverity.critical:
        return 'Critical';
      case AlertSeverity.emergency:
        return 'Emergency';
    }
  }
}

/// The lifecycle status of an alert.
enum AlertStatus {
  active,
  acknowledged,
  resolved,
  expired;

  String get displayName {
    switch (this) {
      case AlertStatus.active:
        return 'Active';
      case AlertStatus.acknowledged:
        return 'Acknowledged';
      case AlertStatus.resolved:
        return 'Resolved';
      case AlertStatus.expired:
        return 'Expired';
    }
  }
}

/// Represents a farm alert notification.
class Alert extends Equatable {
  final String id;
  final AlertType type;
  final String title;
  final String message;
  final AlertSeverity severity;
  final AlertStatus status;
  final String farmId;
  final String? fieldId;
  final String? fieldName;
  final DateTime timestamp;
  final bool read;
  final String? actionUrl;
  final List<String> recommendations;
  final DateTime? acknowledgedAt;
  final String? acknowledgedBy;
  final Map<String, dynamic>? metrics;

  const Alert({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.severity,
    this.status = AlertStatus.active,
    required this.farmId,
    this.fieldId,
    this.fieldName,
    required this.timestamp,
    this.read = false,
    this.actionUrl,
    this.recommendations = const [],
    this.acknowledgedAt,
    this.acknowledgedBy,
    this.metrics,
  });

  bool get isActive => status == AlertStatus.active;
  bool get isAcknowledged => status == AlertStatus.acknowledged;
  bool get isResolved => status == AlertStatus.resolved;

  Alert copyWith({
    String? id,
    AlertType? type,
    String? title,
    String? message,
    AlertSeverity? severity,
    AlertStatus? status,
    String? farmId,
    String? fieldId,
    String? fieldName,
    DateTime? timestamp,
    bool? read,
    String? actionUrl,
    List<String>? recommendations,
    DateTime? acknowledgedAt,
    String? acknowledgedBy,
    Map<String, dynamic>? metrics,
  }) {
    return Alert(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      farmId: farmId ?? this.farmId,
      fieldId: fieldId ?? this.fieldId,
      fieldName: fieldName ?? this.fieldName,
      timestamp: timestamp ?? this.timestamp,
      read: read ?? this.read,
      actionUrl: actionUrl ?? this.actionUrl,
      recommendations: recommendations ?? this.recommendations,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      acknowledgedBy: acknowledgedBy ?? this.acknowledgedBy,
      metrics: metrics ?? this.metrics,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        message,
        severity,
        status,
        farmId,
        fieldId,
        fieldName,
        timestamp,
        read,
        actionUrl,
        recommendations,
        acknowledgedAt,
        acknowledgedBy,
        metrics,
      ];

  @override
  String toString() => 'Alert(id: $id, type: ${type.displayName}, '
      'severity: ${severity.displayName}, status: ${status.displayName})';
}

/// Risk score for a specific field.
class FieldRiskScore extends Equatable {
  final String fieldId;
  final String fieldName;
  final double overallScore;
  final Map<String, double> riskFactors;
  final DateTime calculatedAt;
  final String? trend;

  const FieldRiskScore({
    required this.fieldId,
    required this.fieldName,
    required this.overallScore,
    this.riskFactors = const {},
    required this.calculatedAt,
    this.trend,
  });

  String get riskLabel {
    if (overallScore >= 80) return 'Critical';
    if (overallScore >= 60) return 'High';
    if (overallScore >= 40) return 'Moderate';
    if (overallScore >= 20) return 'Low';
    return 'Minimal';
  }

  @override
  List<Object?> get props =>
      [fieldId, fieldName, overallScore, riskFactors, calculatedAt, trend];
}

/// A configurable alert rule for a field.
class AlertRule extends Equatable {
  final String id;
  final String fieldId;
  final String fieldName;
  final AlertType alertType;
  final bool enabled;
  final double? threshold;
  final AlertSeverity minimumSeverity;
  final bool pushEnabled;
  final bool emailEnabled;
  final bool smsEnabled;

  const AlertRule({
    required this.id,
    required this.fieldId,
    required this.fieldName,
    required this.alertType,
    this.enabled = true,
    this.threshold,
    this.minimumSeverity = AlertSeverity.warning,
    this.pushEnabled = true,
    this.emailEnabled = false,
    this.smsEnabled = false,
  });

  AlertRule copyWith({
    String? id,
    String? fieldId,
    String? fieldName,
    AlertType? alertType,
    bool? enabled,
    double? threshold,
    AlertSeverity? minimumSeverity,
    bool? pushEnabled,
    bool? emailEnabled,
    bool? smsEnabled,
  }) {
    return AlertRule(
      id: id ?? this.id,
      fieldId: fieldId ?? this.fieldId,
      fieldName: fieldName ?? this.fieldName,
      alertType: alertType ?? this.alertType,
      enabled: enabled ?? this.enabled,
      threshold: threshold ?? this.threshold,
      minimumSeverity: minimumSeverity ?? this.minimumSeverity,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      smsEnabled: smsEnabled ?? this.smsEnabled,
    );
  }

  @override
  List<Object?> get props => [
        id,
        fieldId,
        fieldName,
        alertType,
        enabled,
        threshold,
        minimumSeverity,
        pushEnabled,
        emailEnabled,
        smsEnabled,
      ];
}
