import '../../domain/entities/diagnosis_entity.dart';
import '../../domain/entities/treatment_entity.dart';

/// Data model for Diagnosis with JSON/protobuf serialization.
class DiagnosisModel {
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
  final List<TreatmentModel> treatments;
  final DateTime createdAt;

  const DiagnosisModel({
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

  factory DiagnosisModel.fromJson(Map<String, dynamic> json) {
    return DiagnosisModel(
      id: json['id'] as String,
      fieldId: json['field_id'] as String,
      imagePath: json['image_path'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      plantSpecies: json['plant_species'] as String? ?? '',
      diseaseName: json['disease_name'] as String,
      diseaseType: json['disease_type'] as String? ?? '',
      confidence: (json['confidence'] as num).toDouble(),
      severity: DiagnosisSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => DiagnosisSeverity.moderate,
      ),
      description: json['description'] as String,
      recommendations: (json['recommendations'] as List<dynamic>?)
              ?.map((r) => r as String)
              .toList() ??
          [],
      treatments: (json['treatments'] as List<dynamic>?)
              ?.map((t) => TreatmentModel.fromJson(t as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'field_id': fieldId,
      'image_path': imagePath,
      'image_url': imageUrl,
      'plant_species': plantSpecies,
      'disease_name': diseaseName,
      'disease_type': diseaseType,
      'confidence': confidence,
      'severity': severity.name,
      'description': description,
      'recommendations': recommendations,
      'treatments': treatments.map((t) => t.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory DiagnosisModel.fromProto(Map<String, dynamic> proto) {
    return DiagnosisModel(
      id: proto['id'] as String? ?? '',
      fieldId: proto['field_id'] as String? ?? '',
      imagePath: proto['image_path'] as String? ?? '',
      imageUrl: proto['image_url'] as String? ?? '',
      plantSpecies: proto['plant_species'] as String? ?? '',
      diseaseName: proto['disease_name'] as String? ?? '',
      diseaseType: proto['disease_type'] as String? ?? '',
      confidence: (proto['confidence'] as num?)?.toDouble() ?? 0.0,
      severity: DiagnosisSeverity.values.firstWhere(
        (e) => e.name == proto['severity'],
        orElse: () => DiagnosisSeverity.moderate,
      ),
      description: proto['description'] as String? ?? '',
      recommendations: (proto['recommendations'] as List<dynamic>?)
              ?.map((r) => r as String)
              .toList() ??
          [],
      treatments: (proto['treatments'] as List<dynamic>?)
              ?.map((t) => TreatmentModel.fromProto(t as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: proto['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (proto['created_at'] as num).toInt())
          : DateTime.now(),
    );
  }

  Diagnosis toEntity() {
    return Diagnosis(
      id: id,
      fieldId: fieldId,
      imagePath: imagePath,
      imageUrl: imageUrl,
      plantSpecies: plantSpecies,
      diseaseName: diseaseName,
      diseaseType: diseaseType,
      confidence: confidence,
      severity: severity,
      description: description,
      recommendations: recommendations,
      treatments: treatments.map((t) => t.toEntity()).toList(),
      createdAt: createdAt,
    );
  }

  factory DiagnosisModel.fromEntity(Diagnosis entity) {
    return DiagnosisModel(
      id: entity.id,
      fieldId: entity.fieldId,
      imagePath: entity.imagePath,
      imageUrl: entity.imageUrl,
      plantSpecies: entity.plantSpecies,
      diseaseName: entity.diseaseName,
      diseaseType: entity.diseaseType,
      confidence: entity.confidence,
      severity: entity.severity,
      description: entity.description,
      recommendations: entity.recommendations,
      treatments:
          entity.treatments.map((t) => TreatmentModel.fromEntity(t)).toList(),
      createdAt: entity.createdAt,
    );
  }
}

/// Data model for treatment recommendations.
class TreatmentModel {
  final String id;
  final String name;
  final String description;
  final TreatmentType type;
  final TreatmentPriority priority;
  final String applicationMethod;
  final String dosage;
  final String timing;
  final double estimatedCostPerHectare;

  const TreatmentModel({
    required this.id,
    required this.name,
    required this.description,
    this.type = TreatmentType.chemical,
    this.priority = TreatmentPriority.medium,
    this.applicationMethod = '',
    this.dosage = '',
    this.timing = '',
    this.estimatedCostPerHectare = 0.0,
  });

  factory TreatmentModel.fromJson(Map<String, dynamic> json) {
    return TreatmentModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: TreatmentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TreatmentType.chemical,
      ),
      priority: TreatmentPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TreatmentPriority.medium,
      ),
      applicationMethod: json['application_method'] as String? ?? '',
      dosage: json['dosage'] as String? ?? '',
      timing: json['timing'] as String? ?? '',
      estimatedCostPerHectare:
          (json['estimated_cost_per_hectare'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'priority': priority.name,
      'application_method': applicationMethod,
      'dosage': dosage,
      'timing': timing,
      'estimated_cost_per_hectare': estimatedCostPerHectare,
    };
  }

  factory TreatmentModel.fromProto(Map<String, dynamic> proto) {
    return TreatmentModel(
      id: proto['id'] as String? ?? '',
      name: proto['name'] as String? ?? '',
      description: proto['description'] as String? ?? '',
      type: TreatmentType.values.firstWhere(
        (e) => e.name == proto['type'],
        orElse: () => TreatmentType.chemical,
      ),
      priority: TreatmentPriority.values.firstWhere(
        (e) => e.name == proto['priority'],
        orElse: () => TreatmentPriority.medium,
      ),
      applicationMethod: proto['application_method'] as String? ?? '',
      dosage: proto['dosage'] as String? ?? '',
      timing: proto['timing'] as String? ?? '',
      estimatedCostPerHectare:
          (proto['estimated_cost_per_hectare'] as num?)?.toDouble() ?? 0.0,
    );
  }

  TreatmentEntity toEntity() {
    return TreatmentEntity(
      id: id,
      name: name,
      description: description,
      type: type,
      priority: priority,
      applicationMethod: applicationMethod,
      dosage: dosage,
      timing: timing,
      estimatedCostPerHectare: estimatedCostPerHectare,
    );
  }

  factory TreatmentModel.fromEntity(TreatmentEntity entity) {
    return TreatmentModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      type: entity.type,
      priority: entity.priority,
      applicationMethod: entity.applicationMethod,
      dosage: entity.dosage,
      timing: entity.timing,
      estimatedCostPerHectare: entity.estimatedCostPerHectare,
    );
  }
}
