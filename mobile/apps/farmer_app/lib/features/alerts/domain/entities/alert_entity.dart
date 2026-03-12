import 'package:equatable/equatable.dart';

/// The category of an alert.
enum AlertType {
  cropStress,
  waterShortage,
  diseaseOutbreak,
  pestOutbreak,
  irrigationNeeded,
  frostWarning;

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
    }
  }
}

/// The severity level of an alert.
enum AlertSeverity {
  info,
  warning,
  critical;

  String get displayName {
    switch (this) {
      case AlertSeverity.info:
        return 'Info';
      case AlertSeverity.warning:
        return 'Warning';
      case AlertSeverity.critical:
        return 'Critical';
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
  final String farmId;
  final String? fieldId;
  final DateTime timestamp;
  final bool read;
  final String? actionUrl;

  const Alert({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.severity,
    required this.farmId,
    this.fieldId,
    required this.timestamp,
    this.read = false,
    this.actionUrl,
  });

  Alert copyWith({
    String? id,
    AlertType? type,
    String? title,
    String? message,
    AlertSeverity? severity,
    String? farmId,
    String? fieldId,
    DateTime? timestamp,
    bool? read,
    String? actionUrl,
  }) {
    return Alert(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      severity: severity ?? this.severity,
      farmId: farmId ?? this.farmId,
      fieldId: fieldId ?? this.fieldId,
      timestamp: timestamp ?? this.timestamp,
      read: read ?? this.read,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        message,
        severity,
        farmId,
        fieldId,
        timestamp,
        read,
        actionUrl,
      ];

  @override
  String toString() => 'Alert(id: $id, type: ${type.displayName}, '
      'severity: ${severity.displayName})';
}
