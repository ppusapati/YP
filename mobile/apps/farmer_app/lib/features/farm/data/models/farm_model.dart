import 'package:latlong2/latlong.dart';

import '../../domain/entities/farm_entity.dart';
import 'field_model.dart';

/// Data model for Farm with JSON and protobuf serialization support.
class FarmModel {
  final String id;
  final String name;
  final String ownerId;
  final List<LatLng> boundaries;
  final double totalAreaHectares;
  final List<FieldModel> fields;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FarmModel({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.boundaries,
    required this.totalAreaHectares,
    this.fields = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a [FarmModel] from a JSON map.
  factory FarmModel.fromJson(Map<String, dynamic> json) {
    return FarmModel(
      id: json['id'] as String,
      name: json['name'] as String,
      ownerId: json['owner_id'] as String,
      boundaries: (json['boundaries'] as List<dynamic>)
          .map((b) => LatLng(
                (b['latitude'] as num).toDouble(),
                (b['longitude'] as num).toDouble(),
              ))
          .toList(),
      totalAreaHectares: (json['total_area_hectares'] as num).toDouble(),
      fields: (json['fields'] as List<dynamic>?)
              ?.map((f) => FieldModel.fromJson(f as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Converts this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'owner_id': ownerId,
      'boundaries': boundaries
          .map((b) => {
                'latitude': b.latitude,
                'longitude': b.longitude,
              })
          .toList(),
      'total_area_hectares': totalAreaHectares,
      'fields': fields.map((f) => f.toJson()).toList(),
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
      ownerId: proto['owner_id'] as String? ?? '',
      boundaries: boundaryCoords
          .map((b) => LatLng(
                (b['lat'] as num?)?.toDouble() ?? 0.0,
                (b['lng'] as num?)?.toDouble() ?? 0.0,
              ))
          .toList(),
      totalAreaHectares:
          (proto['total_area_hectares'] as num?)?.toDouble() ?? 0.0,
      fields: (proto['fields'] as List<dynamic>?)
              ?.map((f) => FieldModel.fromProto(f as Map<String, dynamic>))
              .toList() ??
          const [],
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
      'owner_id': ownerId,
      'boundaries': boundaries
          .map((b) => {
                'lat': b.latitude,
                'lng': b.longitude,
              })
          .toList(),
      'total_area_hectares': totalAreaHectares,
      'fields': fields.map((f) => f.toProto()).toList(),
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Converts this data model to a domain entity.
  FarmEntity toEntity() {
    return FarmEntity(
      id: id,
      name: name,
      ownerId: ownerId,
      boundaries: boundaries,
      totalAreaHectares: totalAreaHectares,
      fields: fields.map((f) => f.toEntity()).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Creates a [FarmModel] from a domain entity.
  factory FarmModel.fromEntity(FarmEntity entity) {
    return FarmModel(
      id: entity.id,
      name: entity.name,
      ownerId: entity.ownerId,
      boundaries: entity.boundaries,
      totalAreaHectares: entity.totalAreaHectares,
      fields: entity.fields.map((f) => FieldModel.fromEntity(f)).toList(),
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
