import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

/// The type of satellite index being displayed.
enum SatelliteIndexType {
  ndvi,
  evi,
  savi,
  trueColor,
  falseColor,
  moisture;

  String get displayName {
    switch (this) {
      case SatelliteIndexType.ndvi:
        return 'NDVI';
      case SatelliteIndexType.evi:
        return 'EVI';
      case SatelliteIndexType.savi:
        return 'SAVI';
      case SatelliteIndexType.trueColor:
        return 'True Color';
      case SatelliteIndexType.falseColor:
        return 'False Color';
      case SatelliteIndexType.moisture:
        return 'Moisture';
    }
  }
}

/// Represents a satellite imagery tile for a specific field and date.
class SatelliteTileEntity extends Equatable {
  final String id;
  final String fieldId;
  final String tileUrl;
  final DateTime captureDate;
  final SatelliteIndexType indexType;
  final LatLngBounds bounds;

  const SatelliteTileEntity({
    required this.id,
    required this.fieldId,
    required this.tileUrl,
    required this.captureDate,
    required this.indexType,
    required this.bounds,
  });

  SatelliteTileEntity copyWith({
    String? id,
    String? fieldId,
    String? tileUrl,
    DateTime? captureDate,
    SatelliteIndexType? indexType,
    LatLngBounds? bounds,
  }) {
    return SatelliteTileEntity(
      id: id ?? this.id,
      fieldId: fieldId ?? this.fieldId,
      tileUrl: tileUrl ?? this.tileUrl,
      captureDate: captureDate ?? this.captureDate,
      indexType: indexType ?? this.indexType,
      bounds: bounds ?? this.bounds,
    );
  }

  @override
  List<Object?> get props => [id, fieldId, tileUrl, captureDate, indexType, bounds];
}

/// Geographic bounding box defined by southwest and northeast corners.
class LatLngBounds extends Equatable {
  final LatLng southwest;
  final LatLng northeast;

  const LatLngBounds({
    required this.southwest,
    required this.northeast,
  });

  LatLng get center => LatLng(
        (southwest.latitude + northeast.latitude) / 2,
        (southwest.longitude + northeast.longitude) / 2,
      );

  @override
  List<Object?> get props => [southwest, northeast];
}
