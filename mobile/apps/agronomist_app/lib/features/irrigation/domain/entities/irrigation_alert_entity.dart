import 'package:equatable/equatable.dart';

enum IrrigationAlertType {
  lowPressure,
  highFlow,
  leak,
  scheduleMissed,
  sensorOffline,
  systemError,
}

enum IrrigationAlertSeverity {
  info,
  warning,
  critical,
}

class IrrigationAlertEntity extends Equatable {
  const IrrigationAlertEntity({
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
  final IrrigationAlertType type;
  final String message;
  final IrrigationAlertSeverity severity;
  final DateTime timestamp;
  final bool isRead;

  bool get isCritical => severity == IrrigationAlertSeverity.critical;

  IrrigationAlertEntity copyWith({bool? isRead}) {
    return IrrigationAlertEntity(
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
