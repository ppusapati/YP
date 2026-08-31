import 'package:equatable/equatable.dart';

enum IrrigationZoneStatus {
  active,
  inactive,
  irrigating,
  scheduled,
  error,
}

class IrrigationZone extends Equatable {
  const IrrigationZone({
    required this.id,
    required this.fieldId,
    required this.name,
    required this.polygon,
    required this.currentMoisture,
    required this.targetMoisture,
    required this.status,
  });

  final String id;
  final String fieldId;
  final String name;
  final List<LatLngPoint> polygon;
  final double currentMoisture;
  final double targetMoisture;
  final IrrigationZoneStatus status;

  bool get needsIrrigation => currentMoisture < targetMoisture;
  double get moistureDeficit => (targetMoisture - currentMoisture).clamp(0, 100);
  double get moisturePercentage => (currentMoisture / targetMoisture * 100).clamp(0, 100);

  IrrigationZone copyWith({
    String? id,
    String? fieldId,
    String? name,
    List<LatLngPoint>? polygon,
    double? currentMoisture,
    double? targetMoisture,
    IrrigationZoneStatus? status,
  }) {
    return IrrigationZone(
      id: id ?? this.id,
      fieldId: fieldId ?? this.fieldId,
      name: name ?? this.name,
      polygon: polygon ?? this.polygon,
      currentMoisture: currentMoisture ?? this.currentMoisture,
      targetMoisture: targetMoisture ?? this.targetMoisture,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props =>
      [id, fieldId, name, polygon, currentMoisture, targetMoisture, status];
}

class LatLngPoint extends Equatable {
  const LatLngPoint({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  @override
  List<Object?> get props => [latitude, longitude];
}
