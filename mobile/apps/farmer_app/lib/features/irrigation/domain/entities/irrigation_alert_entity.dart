import 'package:equatable/equatable.dart';

enum AlertType {
  lowMoisture,
  highMoisture,
  systemFailure,
  scheduleConflict,
  waterPressureLow,
  sensorOffline,
}

enum AlertSeverity {
  info,
  warning,
  critical,
}

class IrrigationAlert extends Equatable {
  const IrrigationAlert({
    required this.id,
    required this.zoneId,
    required this.type,
    required this.message,
    required this.severity,
    required this.timestamp,
    this.isRead = false,
  });

  final String id;
  final String zoneId;
  final AlertType type;
  final String message;
  final AlertSeverity severity;
  final DateTime timestamp;
  final bool isRead;

  bool get isCritical => severity == AlertSeverity.critical;

  IrrigationAlert copyWith({bool? isRead}) {
    return IrrigationAlert(
      id: id,
      zoneId: zoneId,
      type: type,
      message: message,
      severity: severity,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  List<Object?> get props =>
      [id, zoneId, type, message, severity, timestamp, isRead];
}
