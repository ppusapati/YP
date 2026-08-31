import 'package:equatable/equatable.dart';

/// The type of satellite index being visualized.
enum SatelliteIndexType {
  ndvi,
  ndwi,
  evi,
  savi,
  rgb,
  thermal;

  String get displayName => switch (this) {
        ndvi => 'NDVI',
        ndwi => 'NDWI',
        evi => 'EVI',
        savi => 'SAVI',
        rgb => 'RGB',
        thermal => 'Thermal',
      };
}

/// Represents a single satellite tile with imagery data for a field.
class SatelliteDataEntity extends Equatable {
  final String id;
  final String fieldId;
  final String tileUrl;
  final DateTime captureDate;
  final SatelliteIndexType indexType;

  const SatelliteDataEntity({
    required this.id,
    required this.fieldId,
    required this.tileUrl,
    required this.captureDate,
    required this.indexType,
  });

  SatelliteDataEntity copyWith({
    String? id,
    String? fieldId,
    String? tileUrl,
    DateTime? captureDate,
    SatelliteIndexType? indexType,
  }) {
    return SatelliteDataEntity(
      id: id ?? this.id,
      fieldId: fieldId ?? this.fieldId,
      tileUrl: tileUrl ?? this.tileUrl,
      captureDate: captureDate ?? this.captureDate,
      indexType: indexType ?? this.indexType,
    );
  }

  @override
  List<Object?> get props => [id, fieldId, tileUrl, captureDate, indexType];
}

/// Summary analytics for a field based on satellite data.
class FieldAnalyticsSummary extends Equatable {
  final String farmId;
  final String fieldId;
  final double averageNdvi;
  final double averageNdwi;
  final double healthScore;
  final int totalTiles;
  final DateTime lastCaptureDate;

  const FieldAnalyticsSummary({
    required this.farmId,
    required this.fieldId,
    required this.averageNdvi,
    required this.averageNdwi,
    required this.healthScore,
    required this.totalTiles,
    required this.lastCaptureDate,
  });

  @override
  List<Object?> get props => [
        farmId,
        fieldId,
        averageNdvi,
        averageNdwi,
        healthScore,
        totalTiles,
        lastCaptureDate,
      ];
}

/// Temporal analysis result for a field over time.
class TemporalAnalysis extends Equatable {
  final String farmId;
  final String fieldId;
  final String analysisType;
  final List<TemporalDataPoint> dataPoints;
  final String trend;
  final String summary;

  const TemporalAnalysis({
    required this.farmId,
    required this.fieldId,
    required this.analysisType,
    required this.dataPoints,
    required this.trend,
    required this.summary,
  });

  @override
  List<Object?> get props =>
      [farmId, fieldId, analysisType, dataPoints, trend, summary];
}

/// A single data point in a temporal analysis.
class TemporalDataPoint extends Equatable {
  final DateTime date;
  final double value;

  const TemporalDataPoint({
    required this.date,
    required this.value,
  });

  @override
  List<Object?> get props => [date, value];
}
