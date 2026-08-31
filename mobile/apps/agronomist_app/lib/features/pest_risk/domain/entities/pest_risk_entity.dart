import 'package:equatable/equatable.dart';

enum RiskLevel {
  low,
  moderate,
  high,
  critical;

  String get displayName => switch (this) {
        low => 'Low',
        moderate => 'Moderate',
        high => 'High',
        critical => 'Critical',
      };
}

class PestRiskEntity extends Equatable {
  final String id;
  final String fieldId;
  final RiskLevel riskLevel;
  final String pestType;
  final String description;
  final double probability;
  final DateTime predictedAt;

  const PestRiskEntity({
    required this.id,
    required this.fieldId,
    required this.riskLevel,
    required this.pestType,
    this.description = '',
    required this.probability,
    required this.predictedAt,
  });

  String get probabilityPercent => '${(probability * 100).toStringAsFixed(0)}%';

  @override
  List<Object?> get props =>
      [id, fieldId, riskLevel, pestType, description, probability, predictedAt];
}
