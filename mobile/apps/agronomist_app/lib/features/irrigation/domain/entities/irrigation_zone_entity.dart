import 'package:equatable/equatable.dart';

enum IrrigationZoneStatus {
  active,
  inactive,
  irrigating,
  scheduled,
  error,
}

class IrrigationZoneEntity extends Equatable {
  const IrrigationZoneEntity({
    required this.id,
    required this.fieldId,
    required this.name,
    required this.waterSource,
    required this.areaHectares,
    required this.status,
    required this.flowRate,
  });

  final String id;
  final String fieldId;
  final String name;
  final String waterSource;
  final double areaHectares;
  final IrrigationZoneStatus status;
  final double flowRate;

  bool get isActive => status == IrrigationZoneStatus.active;
  bool get isIrrigating => status == IrrigationZoneStatus.irrigating;
  bool get hasError => status == IrrigationZoneStatus.error;

  IrrigationZoneEntity copyWith({
    String? id,
    String? fieldId,
    String? name,
    String? waterSource,
    double? areaHectares,
    IrrigationZoneStatus? status,
    double? flowRate,
  }) {
    return IrrigationZoneEntity(
      id: id ?? this.id,
      fieldId: fieldId ?? this.fieldId,
      name: name ?? this.name,
      waterSource: waterSource ?? this.waterSource,
      areaHectares: areaHectares ?? this.areaHectares,
      status: status ?? this.status,
      flowRate: flowRate ?? this.flowRate,
    );
  }

  @override
  List<Object?> get props =>
      [id, fieldId, name, waterSource, areaHectares, status, flowRate];
}
