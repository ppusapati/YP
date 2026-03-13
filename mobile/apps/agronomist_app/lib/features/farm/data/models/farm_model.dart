import 'package:latlong2/latlong.dart';

import '../../domain/entities/farm_entity.dart';

/// Data model for Farm with JSON and protobuf serialization support.
class FarmModel {
  final String id;
  final String name;
  final String location;
  final double areaHectares;
  final String ownerName;
  final List<LatLng> boundaries;
  final int fieldCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FarmModel({
    required this.id,
    required this.name,
    required this.location,
    required this.areaHectares,
    required this.ownerName,
    this.boundaries = const [],
    this.fieldCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a [FarmModel] from a JSON map.
  factory FarmModel.fromJson(Map<String, dynamic> json) {
    return FarmModel(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      areaHectares: (json['area_hectares'] as num).toDouble(),
      ownerName: json['owner_name'] as String,
      boundaries: (json['boundaries'] as List<dynamic>?)
              ?.map((b) => LatLng(
                    (b['latitude'] as num).toDouble(),
                    (b['longitude'] as num).toDouble(),
                  ))
              .toList() ??
          const [],
      fieldCount: json['field_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Converts this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'area_hectares': areaHectares,
      'owner_name': ownerName,
      'boundaries': boundaries
          .map((b) => {
                'latitude': b.latitude,
                'longitude': b.longitude,
              })
          .toList(),
      'field_count': fieldCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Creates a [FarmModel] from a protobuf-decoded map.
  ///
  /// Protobuf messages are expected to have been decoded into maps
  /// with snake_case keys matching the proto field names.
  factory FarmModel.fromProto(Map<String, dynamic> proto) {
    final boundaryCoords = proto['boundaries'] as List<dynamic>? ?? [];
    return FarmModel(
      id: proto['id'] as String? ?? '',
      name: proto['name'] as String? ?? '',
      location: proto['location'] as String? ?? '',
      areaHectares:
          (proto['area_hectares'] as num?)?.toDouble() ?? 0.0,
      ownerName: proto['owner_name'] as String? ?? '',
      boundaries: boundaryCoords
          .map((b) => LatLng(
                (b['lat'] as num?)?.toDouble() ?? 0.0,
                (b['lng'] as num?)?.toDouble() ?? 0.0,
              ))
          .toList(),
      fieldCount: (proto['field_count'] as num?)?.toInt() ?? 0,
      createdAt: proto['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (proto['created_at'] as num).toInt())
          : DateTime.now(),
      updatedAt: proto['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (proto['updated_at'] as num).toInt())
          : DateTime.now(),
    );
  }

  /// Converts this model to a protobuf-compatible map.
  Map<String, dynamic> toProto() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'area_hectares': areaHectares,
      'owner_name': ownerName,
      'boundaries': boundaries
          .map((b) => {
                'lat': b.latitude,
                'lng': b.longitude,
              })
          .toList(),
      'field_count': fieldCount,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Converts this data model to a domain entity.
  FarmEntity toEntity() {
    return FarmEntity(
      id: id,
      name: name,
      location: location,
      areaHectares: areaHectares,
      ownerName: ownerName,
      boundaries: boundaries,
      fieldCount: fieldCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Creates a [FarmModel] from a domain entity.
  factory FarmModel.fromEntity(FarmEntity entity) {
    return FarmModel(
      id: entity.id,
      name: entity.name,
      location: entity.location,
      areaHectares: entity.areaHectares,
      ownerName: entity.ownerName,
      boundaries: entity.boundaries,
      fieldCount: entity.fieldCount,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
