import 'package:equatable/equatable.dart';
import 'package:flutter_ui_core/flutter_ui_core.dart' show ModelExplanation;

/// Severity level of a plant disease.
enum DiseaseSeverity {
  mild,
  moderate,
  severe,
  critical;

  String get displayName => switch (this) {
        mild => 'Mild',
        moderate => 'Moderate',
        severe => 'Severe',
        critical => 'Critical',
      };
}

/// Represents a plant disease diagnosis result.
class DiagnosisEntity extends Equatable {
  final String id;
  final String fieldId;
  final String diseaseName;
  final double confidence;
  final DiseaseSeverity severity;
  final String treatment;
  final String? imageUrl;

  /// What the model looked at, one per analysed photo.
  ///
  /// Empty when the serving model cannot explain itself — which is the case
  /// an agronomist reviewing a diagnosis most needs to be able to tell apart
  /// from a model that looked and found nothing.
  final List<ModelExplanation> explanations;

  final DateTime diagnosedAt;

  const DiagnosisEntity({
    required this.id,
    required this.fieldId,
    required this.diseaseName,
    required this.confidence,
    required this.severity,
    required this.treatment,
    this.imageUrl,
    this.explanations = const [],
    required this.diagnosedAt,
  });

  String get confidencePercent => '${(confidence * 100).toStringAsFixed(1)}%';

  DiagnosisEntity copyWith({
    String? id,
    String? fieldId,
    String? diseaseName,
    double? confidence,
    DiseaseSeverity? severity,
    String? treatment,
    String? imageUrl,
    List<ModelExplanation>? explanations,
    DateTime? diagnosedAt,
  }) {
    return DiagnosisEntity(
      id: id ?? this.id,
      fieldId: fieldId ?? this.fieldId,
      diseaseName: diseaseName ?? this.diseaseName,
      confidence: confidence ?? this.confidence,
      severity: severity ?? this.severity,
      treatment: treatment ?? this.treatment,
      imageUrl: imageUrl ?? this.imageUrl,
      explanations: explanations ?? this.explanations,
      diagnosedAt: diagnosedAt ?? this.diagnosedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        fieldId,
        diseaseName,
        confidence,
        severity,
        treatment,
        imageUrl,
        explanations,
        diagnosedAt,
      ];
}
