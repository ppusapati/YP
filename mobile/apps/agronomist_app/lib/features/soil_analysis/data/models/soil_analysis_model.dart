import '../../domain/entities/soil_analysis_entity.dart';

class SoilAnalysisModel {
  final String id;
  final String fieldId;
  final double pH;
  final double nitrogen;
  final double phosphorus;
  final double potassium;
  final double organicMatter;
  final double healthScore;
  final DateTime sampledAt;

  const SoilAnalysisModel({
    required this.id,
    required this.fieldId,
    required this.pH,
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    this.organicMatter = 0,
    required this.healthScore,
    required this.sampledAt,
  });

  factory SoilAnalysisModel.fromJson(Map<String, dynamic> json) {
    return SoilAnalysisModel(
      id: json['id'] as String,
      fieldId: json['field_id'] as String,
      pH: (json['ph'] as num).toDouble(),
      nitrogen: (json['nitrogen'] as num).toDouble(),
      phosphorus: (json['phosphorus'] as num).toDouble(),
      potassium: (json['potassium'] as num).toDouble(),
      organicMatter: (json['organic_matter'] as num?)?.toDouble() ?? 0,
      healthScore: (json['health_score'] as num).toDouble(),
      sampledAt: DateTime.parse(json['sampled_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'field_id': fieldId,
      'ph': pH,
      'nitrogen': nitrogen,
      'phosphorus': phosphorus,
      'potassium': potassium,
      'organic_matter': organicMatter,
      'health_score': healthScore,
      'sampled_at': sampledAt.toIso8601String(),
    };
  }

  SoilAnalysisEntity toEntity() {
    return SoilAnalysisEntity(
      id: id,
      fieldId: fieldId,
      pH: pH,
      nitrogen: nitrogen,
      phosphorus: phosphorus,
      potassium: potassium,
      organicMatter: organicMatter,
      healthScore: healthScore,
      sampledAt: sampledAt,
    );
  }

  factory SoilAnalysisModel.fromEntity(SoilAnalysisEntity entity) {
    return SoilAnalysisModel(
      id: entity.id,
      fieldId: entity.fieldId,
      pH: entity.pH,
      nitrogen: entity.nitrogen,
      phosphorus: entity.phosphorus,
      potassium: entity.potassium,
      organicMatter: entity.organicMatter,
      healthScore: entity.healthScore,
      sampledAt: entity.sampledAt,
    );
  }
}
