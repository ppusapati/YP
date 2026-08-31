import 'package:equatable/equatable.dart';

/// Represents a soil analysis result for a field.
class SoilAnalysisEntity extends Equatable {
  final String id;
  final String fieldId;
  final double pH;
  final double nitrogen;
  final double phosphorus;
  final double potassium;
  final double organicMatter;
  final double healthScore;
  final DateTime sampledAt;

  const SoilAnalysisEntity({
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

  String get healthLabel {
    if (healthScore >= 80) return 'Excellent';
    if (healthScore >= 60) return 'Good';
    if (healthScore >= 40) return 'Fair';
    return 'Poor';
  }

  SoilAnalysisEntity copyWith({
    String? id,
    String? fieldId,
    double? pH,
    double? nitrogen,
    double? phosphorus,
    double? potassium,
    double? organicMatter,
    double? healthScore,
    DateTime? sampledAt,
  }) {
    return SoilAnalysisEntity(
      id: id ?? this.id,
      fieldId: fieldId ?? this.fieldId,
      pH: pH ?? this.pH,
      nitrogen: nitrogen ?? this.nitrogen,
      phosphorus: phosphorus ?? this.phosphorus,
      potassium: potassium ?? this.potassium,
      organicMatter: organicMatter ?? this.organicMatter,
      healthScore: healthScore ?? this.healthScore,
      sampledAt: sampledAt ?? this.sampledAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, fieldId, pH, nitrogen, phosphorus, potassium, organicMatter, healthScore, sampledAt];
}
