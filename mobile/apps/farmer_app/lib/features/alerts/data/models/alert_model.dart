import '../../domain/entities/alert_entity.dart';

class AlertModel extends Alert {
  const AlertModel({
    required super.id,
    required super.type,
    required super.title,
    required super.message,
    required super.severity,
    required super.farmId,
    super.fieldId,
    required super.timestamp,
    super.read,
    super.actionUrl,
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
      farmId: json['farm_id'] as String,
      fieldId: json['field_id'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      read: json['read'] as bool? ?? false,
      actionUrl: json['action_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'message': message,
      'severity': severity.name,
      'farm_id': farmId,
      'field_id': fieldId,
      'timestamp': timestamp.toIso8601String(),
      'read': read,
      'action_url': actionUrl,
    };
  }

  factory AlertModel.fromEntity(Alert alert) {
    return AlertModel(
      id: alert.id,
      type: alert.type,
      title: alert.title,
      message: alert.message,
      severity: alert.severity,
      farmId: alert.farmId,
      fieldId: alert.fieldId,
      timestamp: alert.timestamp,
      read: alert.read,
      actionUrl: alert.actionUrl,
    );
  }
}
