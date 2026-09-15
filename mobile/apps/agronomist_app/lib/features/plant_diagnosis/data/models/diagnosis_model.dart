import 'package:flutter_ui_core/flutter_ui_core.dart' show ModelExplanation;

import '../../domain/entities/diagnosis_entity.dart';

class DiagnosisModel {
  final String id;
  final String fieldId;
  final String diseaseName;
  final double confidence;
  final String severity;
  final String treatment;
  final String? imageUrl;
  final List<ModelExplanation> explanations;
  final DateTime diagnosedAt;

  const DiagnosisModel({
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

  factory DiagnosisModel.fromJson(Map<String, dynamic> json) {
    return DiagnosisModel(
      id: json['id'] as String,
      fieldId: json['field_id'] as String,
      diseaseName: json['disease_name'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      severity: json['severity'] as String? ?? 'mild',
      treatment: json['treatment'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      explanations: (json['explanations'] as List<dynamic>?)
              ?.map((e) => ModelExplanation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      diagnosedAt: DateTime.parse(json['diagnosed_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'field_id': fieldId,
      'disease_name': diseaseName,
      'confidence': confidence,
      'severity': severity,
      'treatment': treatment,
      if (imageUrl != null) 'image_url': imageUrl,
      'explanations': explanations.map((e) => e.toJson()).toList(),
      'diagnosed_at': diagnosedAt.toIso8601String(),
    };
  }

  DiagnosisEntity toEntity() {
    return DiagnosisEntity(
      id: id,
      fieldId: fieldId,
      diseaseName: diseaseName,
      confidence: confidence,
      severity: DiseaseSeverity.values.firstWhere(
        (e) => e.name == severity,
        orElse: () => DiseaseSeverity.mild,
      ),
      treatment: treatment,
      imageUrl: imageUrl,
      explanations: explanations,
      diagnosedAt: diagnosedAt,
    );
  }

  factory DiagnosisModel.fromEntity(DiagnosisEntity entity) {
    return DiagnosisModel(
      id: entity.id,
      fieldId: entity.fieldId,
      diseaseName: entity.diseaseName,
      confidence: entity.confidence,
      severity: entity.severity.name,
      treatment: entity.treatment,
      imageUrl: entity.imageUrl,
      explanations: entity.explanations,
      diagnosedAt: entity.diagnosedAt,
    );
  }
}
