import '../../domain/entities/satellite_data_entity.dart';

class SatelliteDataModel {
  final String id;
  final String fieldId;
  final String tileUrl;
  final DateTime captureDate;
  final String indexType;

  const SatelliteDataModel({
    required this.id,
    required this.fieldId,
    required this.tileUrl,
    required this.captureDate,
    required this.indexType,
  });

  factory SatelliteDataModel.fromJson(Map<String, dynamic> json) {
    return SatelliteDataModel(
      id: json['id'] as String,
      fieldId: json['field_id'] as String,
      tileUrl: json['tile_url'] as String,
      captureDate: DateTime.parse(json['capture_date'] as String),
      indexType: json['index_type'] as String? ?? 'ndvi',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'field_id': fieldId,
      'tile_url': tileUrl,
      'capture_date': captureDate.toIso8601String(),
      'index_type': indexType,
    };
  }

  SatelliteDataEntity toEntity() {
    return SatelliteDataEntity(
      id: id,
      fieldId: fieldId,
      tileUrl: tileUrl,
      captureDate: captureDate,
      indexType: SatelliteIndexType.values.firstWhere(
        (e) => e.name == indexType,
        orElse: () => SatelliteIndexType.ndvi,
      ),
    );
  }
}

class StressAlertModel {
  final String id;
  final String farmId;
  final String fieldId;
  final String stressType;
  final String severity;
  final double confidence;
  final double affectedArea;
  final DateTime detectedAt;

  const StressAlertModel({
    required this.id,
    required this.farmId,
    required this.fieldId,
    required this.stressType,
    required this.severity,
    required this.confidence,
    required this.affectedArea,
    required this.detectedAt,
  });

  factory StressAlertModel.fromJson(Map<String, dynamic> json) {
    return StressAlertModel(
      id: json['id'] as String,
      farmId: json['farm_id'] as String,
      fieldId: json['field_id'] as String,
      stressType: json['stress_type'] as String? ?? 'unknown',
      severity: json['severity'] as String? ?? 'low',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      affectedArea: (json['affected_area'] as num?)?.toDouble() ?? 0,
      detectedAt: DateTime.parse(json['detected_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farm_id': farmId,
      'field_id': fieldId,
      'stress_type': stressType,
      'severity': severity,
      'confidence': confidence,
      'affected_area': affectedArea,
      'detected_at': detectedAt.toIso8601String(),
    };
  }

  StressAlertEntity toEntity() {
    return StressAlertEntity(
      id: id,
      farmId: farmId,
      fieldId: fieldId,
      stressType: StressType.values.firstWhere(
        (e) => e.name == stressType,
        orElse: () => StressType.unknown,
      ),
      severity: StressSeverity.values.firstWhere(
        (e) => e.name == severity,
        orElse: () => StressSeverity.low,
      ),
      confidence: confidence,
      affectedArea: affectedArea,
      detectedAt: detectedAt,
    );
  }
}
