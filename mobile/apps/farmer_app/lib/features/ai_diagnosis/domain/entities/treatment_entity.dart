import 'package:equatable/equatable.dart';

/// Priority level for a treatment recommendation.
enum TreatmentPriority {
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

/// Type of treatment action.
enum TreatmentType {
  chemical,
  biological,
  cultural,
  mechanical,
  preventive;

  String get displayName => switch (this) {
        chemical => 'Chemical',
        biological => 'Biological',
        cultural => 'Cultural',
        mechanical => 'Mechanical',
        preventive => 'Preventive',
      };
}

/// Represents a treatment recommendation for a diagnosed plant disease.
class TreatmentEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final TreatmentType type;
  final TreatmentPriority priority;
  final String applicationMethod;
  final String dosage;
  final String timing;
  final double estimatedCostPerHectare;

  const TreatmentEntity({
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

  TreatmentEntity copyWith({
    String? id,
    String? name,
    String? description,
    TreatmentType? type,
    TreatmentPriority? priority,
    String? applicationMethod,
    String? dosage,
    String? timing,
    double? estimatedCostPerHectare,
  }) {
    return TreatmentEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      applicationMethod: applicationMethod ?? this.applicationMethod,
      dosage: dosage ?? this.dosage,
      timing: timing ?? this.timing,
      estimatedCostPerHectare:
          estimatedCostPerHectare ?? this.estimatedCostPerHectare,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        type,
        priority,
        applicationMethod,
        dosage,
        timing,
        estimatedCostPerHectare,
      ];
}
