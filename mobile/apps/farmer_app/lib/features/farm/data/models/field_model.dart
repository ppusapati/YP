import 'package:latlong2/latlong.dart';

import '../../domain/entities/field_entity.dart';

/// Data model for Field with JSON and protobuf serialization support.
class FieldModel {
  final String id;
  final String farmId;
  final String name;
  final List<LatLng> polygon;
  final double areaHectares;
  final CropType cropType;
  final SoilType soilType;
  final FieldStatus status;

  const FieldModel({
    required this.id,
    required this.farmId,
    required this.name,
    required this.polygon,
    required this.areaHectares,
    this.cropType = CropType.none,
    this.soilType = SoilType.unknown,
    this.status = FieldStatus.active,
  });

  factory FieldModel.fromJson(Map<String, dynamic> json) {
    return FieldModel(
      id: json['id'] as String,
      farmId: json['farm_id'] as String,
      name: json['name'] as String,
      polygon: (json['polygon'] as List<dynamic>)
          .map((p) => LatLng(
                (p['latitude'] as num).toDouble(),
                (p['longitude'] as num).toDouble(),
              ))
          .toList(),
      areaHectares: (json['area_hectares'] as num).toDouble(),
      cropType: CropType.values.firstWhere(
        (e) => e.name == json['crop_type'],
        orElse: () => CropType.none,
      ),
      soilType: SoilType.values.firstWhere(
        (e) => e.name == json['soil_type'],
        orElse: () => SoilType.unknown,
      ),
      status: FieldStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => FieldStatus.active,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farm_id': farmId,
      'name': name,
      'polygon': polygon
          .map((p) => {
                'latitude': p.latitude,
                'longitude': p.longitude,
              })
          .toList(),
      'area_hectares': areaHectares,
      'crop_type': cropType.name,
      'soil_type': soilType.name,
      'status': status.name,
    };
  }

  factory FieldModel.fromProto(Map<String, dynamic> proto) {
    final coords = proto['polygon'] as List<dynamic>? ?? [];
    return FieldModel(
      id: proto['id'] as String? ?? '',
      farmId: proto['farm_id'] as String? ?? '',
      name: proto['name'] as String? ?? '',
      polygon: coords
          .map((p) => LatLng(
                (p['lat'] as num?)?.toDouble() ?? 0.0,
                (p['lng'] as num?)?.toDouble() ?? 0.0,
              ))
          .toList(),
      areaHectares: (proto['area_hectares'] as num?)?.toDouble() ?? 0.0,
      cropType: CropType.values.firstWhere(
        (e) => e.name == proto['crop_type'],
        orElse: () => CropType.none,
      ),
      soilType: SoilType.values.firstWhere(
        (e) => e.name == proto['soil_type'],
        orElse: () => SoilType.unknown,
      ),
      status: FieldStatus.values.firstWhere(
        (e) => e.name == proto['status'],
        orElse: () => FieldStatus.active,
      ),
    );
  }

  Map<String, dynamic> toProto() {
    return {
      'id': id,
      'farm_id': farmId,
      'name': name,
      'polygon': polygon
          .map((p) => {
                'lat': p.latitude,
                'lng': p.longitude,
              })
          .toList(),
      'area_hectares': areaHectares,
      'crop_type': cropType.name,
      'soil_type': soilType.name,
      'status': status.name,
    };
  }

  FieldEntity toEntity() {
    return FieldEntity(
      id: id,
      farmId: farmId,
      name: name,
      polygon: polygon,
      areaHectares: areaHectares,
      cropType: cropType,
      soilType: soilType,
      status: status,
    );
  }

  factory FieldModel.fromEntity(FieldEntity entity) {
    return FieldModel(
      id: entity.id,
      farmId: entity.farmId,
      name: entity.name,
      polygon: entity.polygon,
      areaHectares: entity.areaHectares,
      cropType: entity.cropType,
      soilType: entity.soilType,
      status: entity.status,
    );
  }
}
