import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

import 'field_entity.dart';

/// Represents a farm with its geographic boundaries and associated fields.
class FarmEntity extends Equatable {
  final String id;
  final String name;
  final String ownerId;
  final List<LatLng> boundaries;
  final double totalAreaHectares;
  final List<FieldEntity> fields;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FarmEntity({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.boundaries,
    required this.totalAreaHectares,
    this.fields = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  FarmEntity copyWith({
    String? id,
    String? name,
    String? ownerId,
    List<LatLng>? boundaries,
    double? totalAreaHectares,
    List<FieldEntity>? fields,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FarmEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerId: ownerId ?? this.ownerId,
      boundaries: boundaries ?? this.boundaries,
      totalAreaHectares: totalAreaHectares ?? this.totalAreaHectares,
      fields: fields ?? this.fields,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// The number of active fields within this farm.
  int get activeFieldCount =>
      fields.where((f) => f.status == FieldStatus.active).length;

  /// The total area covered by mapped fields.
  double get mappedAreaHectares =>
      fields.fold(0.0, (sum, f) => sum + f.areaHectares);

  @override
  List<Object?> get props => [
        id,
        name,
        ownerId,
        boundaries,
        totalAreaHectares,
        fields,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() => 'FarmEntity(id: $id, name: $name)';
}
