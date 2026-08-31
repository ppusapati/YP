import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

/// Status of a field within a farm.
enum FieldStatus {
  active,
  fallow,
  planned,
  archived;

  String get displayName {
    switch (this) {
      case FieldStatus.active:
        return 'Active';
      case FieldStatus.fallow:
        return 'Fallow';
      case FieldStatus.planned:
        return 'Planned';
      case FieldStatus.archived:
        return 'Archived';
    }
  }
}

/// The type of crop currently planted in a field.
enum CropType {
  wheat,
  corn,
  soybean,
  rice,
  cotton,
  sugarcane,
  barley,
  sunflower,
  potato,
  tomato,
  other,
  none;

  String get displayName {
    switch (this) {
      case CropType.wheat:
        return 'Wheat';
      case CropType.corn:
        return 'Corn';
      case CropType.soybean:
        return 'Soybean';
      case CropType.rice:
        return 'Rice';
      case CropType.cotton:
        return 'Cotton';
      case CropType.sugarcane:
        return 'Sugarcane';
      case CropType.barley:
        return 'Barley';
      case CropType.sunflower:
        return 'Sunflower';
      case CropType.potato:
        return 'Potato';
      case CropType.tomato:
        return 'Tomato';
      case CropType.other:
        return 'Other';
      case CropType.none:
        return 'None';
    }
  }
}

/// The soil type classification for a field.
enum SoilType {
  clay,
  sandy,
  loamy,
  silt,
  peat,
  chalky,
  unknown;

  String get displayName {
    switch (this) {
      case SoilType.clay:
        return 'Clay';
      case SoilType.sandy:
        return 'Sandy';
      case SoilType.loamy:
        return 'Loamy';
      case SoilType.silt:
        return 'Silt';
      case SoilType.peat:
        return 'Peat';
      case SoilType.chalky:
        return 'Chalky';
      case SoilType.unknown:
        return 'Unknown';
    }
  }
}

/// Represents a single field (parcel) within a farm.
class FieldEntity extends Equatable {
  final String id;
  final String farmId;
  final String name;
  final List<LatLng> polygon;
  final double areaHectares;
  final CropType cropType;
  final SoilType soilType;
  final FieldStatus status;

  const FieldEntity({
    required this.id,
    required this.farmId,
    required this.name,
    required this.polygon,
    required this.areaHectares,
    this.cropType = CropType.none,
    this.soilType = SoilType.unknown,
    this.status = FieldStatus.active,
  });

  FieldEntity copyWith({
    String? id,
    String? farmId,
    String? name,
    List<LatLng>? polygon,
    double? areaHectares,
    CropType? cropType,
    SoilType? soilType,
    FieldStatus? status,
  }) {
    return FieldEntity(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      name: name ?? this.name,
      polygon: polygon ?? this.polygon,
      areaHectares: areaHectares ?? this.areaHectares,
      cropType: cropType ?? this.cropType,
      soilType: soilType ?? this.soilType,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        id,
        farmId,
        name,
        polygon,
        areaHectares,
        cropType,
        soilType,
        status,
      ];

  @override
  String toString() =>
      'FieldEntity(id: $id, name: $name, crop: ${cropType.displayName})';
}
