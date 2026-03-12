import '../../domain/entities/irrigation_zone_entity.dart';

class LatLngPointModel extends LatLngPoint {
  const LatLngPointModel({
    required super.latitude,
    required super.longitude,
  });

  factory LatLngPointModel.fromJson(Map<String, dynamic> json) {
    return LatLngPointModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
      };
}

class IrrigationZoneModel extends IrrigationZone {
  const IrrigationZoneModel({
    required super.id,
    required super.fieldId,
    required super.name,
    required super.polygon,
    required super.currentMoisture,
    required super.targetMoisture,
    required super.status,
  });

  factory IrrigationZoneModel.fromJson(Map<String, dynamic> json) {
    return IrrigationZoneModel(
      id: json['id'] as String,
      fieldId: json['field_id'] as String,
      name: json['name'] as String,
      polygon: (json['polygon'] as List<dynamic>)
          .map((e) => LatLngPointModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentMoisture: (json['current_moisture'] as num).toDouble(),
      targetMoisture: (json['target_moisture'] as num).toDouble(),
      status: IrrigationZoneStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => IrrigationZoneStatus.inactive,
      ),
    );
  }

  factory IrrigationZoneModel.fromEntity(IrrigationZone entity) {
    return IrrigationZoneModel(
      id: entity.id,
      fieldId: entity.fieldId,
      name: entity.name,
      polygon: entity.polygon,
      currentMoisture: entity.currentMoisture,
      targetMoisture: entity.targetMoisture,
      status: entity.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'field_id': fieldId,
      'name': name,
      'polygon': polygon
          .map((p) => {'latitude': p.latitude, 'longitude': p.longitude})
          .toList(),
      'current_moisture': currentMoisture,
      'target_moisture': targetMoisture,
      'status': status.name,
    };
  }
}
