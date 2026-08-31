import 'package:equatable/equatable.dart';

/// Type of vegetation stress detected by satellite analysis.
enum StressType {
  water,
  nutrient,
  disease,
  heat,
  frost,
  unknown;

  String get displayName => switch (this) {
        water => 'Water Stress',
        nutrient => 'Nutrient Deficiency',
        disease => 'Disease',
        heat => 'Heat Stress',
        frost => 'Frost Damage',
        unknown => 'Unknown',
      };
}

/// Severity level of a stress alert.
enum StressSeverity {
  low,
  medium,
  high,
  critical;

  String get displayName => switch (this) {
        low => 'Low',
        medium => 'Medium',
        high => 'High',
        critical => 'Critical',
      };
}

/// Represents a stress alert detected from satellite imagery.
class StressAlertEntity extends Equatable {
  final String id;
  final String farmId;
  final String fieldId;
  final StressType stressType;
  final StressSeverity severity;
  final double confidence;
  final double affectedArea;
  final DateTime detectedAt;

  const StressAlertEntity({
    required this.id,
    required this.farmId,
    required this.fieldId,
    required this.stressType,
    required this.severity,
    required this.confidence,
    required this.affectedArea,
    required this.detectedAt,
  });

  /// A formatted confidence percentage string.
  String get confidencePercent => '${(confidence * 100).toStringAsFixed(1)}%';

  /// A formatted affected area string in hectares.
  String get affectedAreaFormatted => '${affectedArea.toStringAsFixed(2)} ha';

  /// Whether this alert is critical severity.
  bool get isCritical => severity == StressSeverity.critical;

  StressAlertEntity copyWith({
    String? id,
    String? farmId,
    String? fieldId,
    StressType? stressType,
    StressSeverity? severity,
    double? confidence,
    double? affectedArea,
    DateTime? detectedAt,
  }) {
    return StressAlertEntity(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      fieldId: fieldId ?? this.fieldId,
      stressType: stressType ?? this.stressType,
      severity: severity ?? this.severity,
      confidence: confidence ?? this.confidence,
      affectedArea: affectedArea ?? this.affectedArea,
      detectedAt: detectedAt ?? this.detectedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        farmId,
        fieldId,
        stressType,
        severity,
        confidence,
        affectedArea,
        detectedAt,
      ];
}
