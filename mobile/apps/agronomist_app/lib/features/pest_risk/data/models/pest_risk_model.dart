import '../../domain/entities/pest_risk_entity.dart';

class PestRiskModel {
  final String id;
  final String fieldId;
  final String riskLevel;
  final String pestType;
  final String description;
  final double probability;
  final DateTime predictedAt;

  const PestRiskModel({
    required this.id,
    required this.fieldId,
    required this.riskLevel,
    required this.pestType,
    this.description = '',
    required this.probability,
    required this.predictedAt,
  });

  factory PestRiskModel.fromJson(Map<String, dynamic> json) {
    return PestRiskModel(
      id: json['id'] as String,
      fieldId: json['field_id'] as String,
      riskLevel: json['risk_level'] as String? ?? 'low',
      pestType: json['pest_type'] as String,
      description: json['description'] as String? ?? '',
      probability: (json['probability'] as num).toDouble(),
      predictedAt: DateTime.parse(json['predicted_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'field_id': fieldId,
      'risk_level': riskLevel,
      'pest_type': pestType,
      'description': description,
      'probability': probability,
      'predicted_at': predictedAt.toIso8601String(),
    };
  }

  PestRiskEntity toEntity() {
    return PestRiskEntity(
      id: id,
      fieldId: fieldId,
      riskLevel: RiskLevel.values.firstWhere(
        (e) => e.name == riskLevel,
        orElse: () => RiskLevel.low,
      ),
      pestType: pestType,
      description: description,
      probability: probability,
      predictedAt: predictedAt,
    );
  }
}
