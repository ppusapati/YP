import '../../domain/entities/soil_analysis_entity.dart';

class SoilAnalysisModel extends SoilAnalysis {
  const SoilAnalysisModel({
    required super.id,
    required super.fieldId,
    required super.pH,
    required super.organicCarbon,
    required super.nitrogen,
    required super.phosphorus,
    required super.potassium,
    required super.texture,
    required super.analysisDate,
    super.fieldName,
  });

  factory SoilAnalysisModel.fromJson(Map<String, dynamic> json) {
    return SoilAnalysisModel(
      id: json['id'] as String,
      fieldId: json['field_id'] as String,
      pH: (json['ph'] as num).toDouble(),
      organicCarbon: (json['organic_carbon'] as num).toDouble(),
      nitrogen: (json['nitrogen'] as num).toDouble(),
      phosphorus: (json['phosphorus'] as num).toDouble(),
      potassium: (json['potassium'] as num).toDouble(),
      texture: SoilTexture.values.firstWhere(
        (e) => e.name == json['texture'],
        orElse: () => SoilTexture.loamy,
      ),
      analysisDate: DateTime.parse(json['analysis_date'] as String),
      fieldName: json['field_name'] as String?,
    );
  }

  factory SoilAnalysisModel.fromEntity(SoilAnalysis entity) {
    return SoilAnalysisModel(
      id: entity.id,
      fieldId: entity.fieldId,
      pH: entity.pH,
      organicCarbon: entity.organicCarbon,
      nitrogen: entity.nitrogen,
      phosphorus: entity.phosphorus,
      potassium: entity.potassium,
      texture: entity.texture,
      analysisDate: entity.analysisDate,
      fieldName: entity.fieldName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'field_id': fieldId,
      'ph': pH,
      'organic_carbon': organicCarbon,
      'nitrogen': nitrogen,
      'phosphorus': phosphorus,
      'potassium': potassium,
      'texture': texture.name,
      'analysis_date': analysisDate.toIso8601String(),
      'field_name': fieldName,
    };
  }
}
