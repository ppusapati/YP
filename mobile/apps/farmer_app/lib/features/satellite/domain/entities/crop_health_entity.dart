import 'package:equatable/equatable.dart';

/// Represents a time-series data point for crop health monitoring.
class CropHealthDataPoint extends Equatable {
  final DateTime date;
  final double ndviMean;
  final double ndviMin;
  final double ndviMax;
  final double growthRate;

  const CropHealthDataPoint({
    required this.date,
    required this.ndviMean,
    required this.ndviMin,
    required this.ndviMax,
    this.growthRate = 0.0,
  });

  @override
  List<Object?> get props => [date, ndviMean, ndviMin, ndviMax, growthRate];
}

/// Represents overall crop health status for a field over time.
class CropHealthEntity extends Equatable {
  final String fieldId;
  final String fieldName;
  final List<CropHealthDataPoint> timeSeries;
  final CropHealthStatus overallStatus;
  final double currentNdvi;
  final double trendPercent;
  final DateTime lastUpdated;

  const CropHealthEntity({
    required this.fieldId,
    required this.fieldName,
    required this.timeSeries,
    required this.overallStatus,
    required this.currentNdvi,
    required this.trendPercent,
    required this.lastUpdated,
  });

  /// Whether the crop health trend is improving.
  bool get isImproving => trendPercent > 0;

  CropHealthEntity copyWith({
    String? fieldId,
    String? fieldName,
    List<CropHealthDataPoint>? timeSeries,
    CropHealthStatus? overallStatus,
    double? currentNdvi,
    double? trendPercent,
    DateTime? lastUpdated,
  }) {
    return CropHealthEntity(
      fieldId: fieldId ?? this.fieldId,
      fieldName: fieldName ?? this.fieldName,
      timeSeries: timeSeries ?? this.timeSeries,
      overallStatus: overallStatus ?? this.overallStatus,
      currentNdvi: currentNdvi ?? this.currentNdvi,
      trendPercent: trendPercent ?? this.trendPercent,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
        fieldId,
        fieldName,
        timeSeries,
        overallStatus,
        currentNdvi,
        trendPercent,
        lastUpdated,
      ];
}

/// Overall health classification for a crop.
enum CropHealthStatus {
  excellent,
  good,
  moderate,
  stressed,
  critical;

  String get displayName {
    switch (this) {
      case CropHealthStatus.excellent:
        return 'Excellent';
      case CropHealthStatus.good:
        return 'Good';
      case CropHealthStatus.moderate:
        return 'Moderate';
      case CropHealthStatus.stressed:
        return 'Stressed';
      case CropHealthStatus.critical:
        return 'Critical';
    }
  }
}
