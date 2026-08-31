import '../../domain/entities/satellite_entity.dart';

/// Data model for satellite tiles with JSON/protobuf serialization.
class SatelliteTileModel {
  final String id;
  final String fieldId;
  final SatelliteLayerType layerType;
  final String tileUrl;
  final DateTime captureDate;
  final double cloudCoverPercent;

  const SatelliteTileModel({
    required this.id,
    required this.fieldId,
    required this.layerType,
    required this.tileUrl,
    required this.captureDate,
    required this.cloudCoverPercent,
  });

  factory SatelliteTileModel.fromJson(Map<String, dynamic> json) {
    return SatelliteTileModel(
      id: json['id'] as String,
      fieldId: json['field_id'] as String,
      layerType: SatelliteLayerType.values.firstWhere(
        (e) => e.name == json['layer_type'],
        orElse: () => SatelliteLayerType.ndvi,
      ),
      tileUrl: json['tile_url'] as String,
      captureDate: DateTime.parse(json['capture_date'] as String),
      cloudCoverPercent: (json['cloud_cover_percent'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'field_id': fieldId,
      'layer_type': layerType.name,
      'tile_url': tileUrl,
      'capture_date': captureDate.toIso8601String(),
      'cloud_cover_percent': cloudCoverPercent,
    };
  }

  factory SatelliteTileModel.fromProto(Map<String, dynamic> proto) {
    return SatelliteTileModel(
      id: proto['id'] as String? ?? '',
      fieldId: proto['field_id'] as String? ?? '',
      layerType: SatelliteLayerType.values.firstWhere(
        (e) => e.name == proto['layer_type'],
        orElse: () => SatelliteLayerType.ndvi,
      ),
      tileUrl: proto['tile_url'] as String? ?? '',
      captureDate: proto['capture_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (proto['capture_date'] as num).toInt())
          : DateTime.now(),
      cloudCoverPercent:
          (proto['cloud_cover_percent'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toProto() {
    return {
      'id': id,
      'field_id': fieldId,
      'layer_type': layerType.name,
      'tile_url': tileUrl,
      'capture_date': captureDate.millisecondsSinceEpoch,
      'cloud_cover_percent': cloudCoverPercent,
    };
  }

  SatelliteTile toEntity() {
    return SatelliteTile(
      id: id,
      fieldId: fieldId,
      layerType: layerType,
      tileUrl: tileUrl,
      captureDate: captureDate,
      cloudCoverPercent: cloudCoverPercent,
    );
  }

  factory SatelliteTileModel.fromEntity(SatelliteTile entity) {
    return SatelliteTileModel(
      id: entity.id,
      fieldId: entity.fieldId,
      layerType: entity.layerType,
      tileUrl: entity.tileUrl,
      captureDate: entity.captureDate,
      cloudCoverPercent: entity.cloudCoverPercent,
    );
  }
}
