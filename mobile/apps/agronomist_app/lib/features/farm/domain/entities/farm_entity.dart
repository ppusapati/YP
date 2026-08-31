import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

/// Represents a client farm managed by an agronomist.
///
/// Unlike the farmer app, the agronomist can manage ALL farms across
/// multiple clients, not just their own.
class FarmEntity extends Equatable {
  final String id;
  final String name;
  final String location;
  final double areaHectares;
  final String ownerName;
  final List<LatLng> boundaries;
  final int fieldCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FarmEntity({
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

  FarmEntity copyWith({
    String? id,
    String? name,
    String? location,
    double? areaHectares,
    String? ownerName,
    List<LatLng>? boundaries,
    int? fieldCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FarmEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      areaHectares: areaHectares ?? this.areaHectares,
      ownerName: ownerName ?? this.ownerName,
      boundaries: boundaries ?? this.boundaries,
      fieldCount: fieldCount ?? this.fieldCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        location,
        areaHectares,
        ownerName,
        boundaries,
        fieldCount,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() => 'FarmEntity(id: $id, name: $name, owner: $ownerName)';
}
