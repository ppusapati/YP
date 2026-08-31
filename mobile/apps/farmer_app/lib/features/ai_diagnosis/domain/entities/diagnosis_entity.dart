import 'package:equatable/equatable.dart';

import 'treatment_entity.dart';

/// Severity classification for a plant disease diagnosis.
enum DiagnosisSeverity {
  healthy,
  mild,
  moderate,
  severe;

  String get displayName => switch (this) {
        healthy => 'Healthy',
        mild => 'Mild',
        moderate => 'Moderate',
        severe => 'Severe',
      };
}

/// Represents a complete AI plant disease diagnosis result.
class Diagnosis extends Equatable {
  final String id;
  final String fieldId;
  final String imagePath;
  final String imageUrl;
  final String plantSpecies;
  final String diseaseName;
  final String diseaseType;
  final double confidence;
  final DiagnosisSeverity severity;
  final String description;
  final List<String> recommendations;
  final List<TreatmentEntity> treatments;
  final DateTime createdAt;

  const Diagnosis({
    required this.id,
    required this.fieldId,
    required this.imagePath,
    this.imageUrl = '',
    this.plantSpecies = '',
    required this.diseaseName,
    this.diseaseType = '',
    required this.confidence,
    required this.severity,
    required this.description,
    required this.recommendations,
    this.treatments = const [],
    required this.createdAt,
  });

  Diagnosis copyWith({
    String? id,
    String? fieldId,
    String? imagePath,
    String? imageUrl,
    String? plantSpecies,
    String? diseaseName,
    String? diseaseType,
    double? confidence,
    DiagnosisSeverity? severity,
    String? description,
    List<String>? recommendations,
    List<TreatmentEntity>? treatments,
    DateTime? createdAt,
  }) {
    return Diagnosis(
      id: id ?? this.id,
      fieldId: fieldId ?? this.fieldId,
      imagePath: imagePath ?? this.imagePath,
      imageUrl: imageUrl ?? this.imageUrl,
      plantSpecies: plantSpecies ?? this.plantSpecies,
      diseaseName: diseaseName ?? this.diseaseName,
      diseaseType: diseaseType ?? this.diseaseType,
      confidence: confidence ?? this.confidence,
      severity: severity ?? this.severity,
      description: description ?? this.description,
      recommendations: recommendations ?? this.recommendations,
      treatments: treatments ?? this.treatments,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Whether the plant is diagnosed as healthy.
  bool get isHealthy => severity == DiagnosisSeverity.healthy;

  /// A formatted confidence percentage string.
  String get confidencePercent => '${(confidence * 100).toStringAsFixed(1)}%';

  @override
  List<Object?> get props => [
        id,
        fieldId,
        imagePath,
        imageUrl,
        plantSpecies,
        diseaseName,
        diseaseType,
        confidence,
        severity,
        description,
        recommendations,
        treatments,
        createdAt,
      ];
}
