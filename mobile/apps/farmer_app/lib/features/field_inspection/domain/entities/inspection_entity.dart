import 'package:equatable/equatable.dart';

/// Severity of an issue found during inspection.
enum IssueSeverity {
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

/// A single issue recorded during a field inspection.
class InspectionIssue extends Equatable {
  final String description;
  final IssueSeverity severity;
  final String? photoUrl;

  const InspectionIssue({
    required this.description,
    required this.severity,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [description, severity, photoUrl];
}

/// Represents a field inspection performed by the agronomist.
class InspectionEntity extends Equatable {
  final String id;
  final String fieldId;
  final String farmId;
  final DateTime date;
  final String notes;
  final double healthScore;
  final List<InspectionIssue> issues;
  final String status;

  const InspectionEntity({
    required this.id,
    required this.fieldId,
    required this.farmId,
    required this.date,
    this.notes = '',
    required this.healthScore,
    this.issues = const [],
    this.status = 'draft',
  });

  bool get isDraft => status == 'draft';
  bool get isSubmitted => status == 'submitted';
  String get healthLabel {
    if (healthScore >= 80) return 'Healthy';
    if (healthScore >= 60) return 'Fair';
    if (healthScore >= 40) return 'Poor';
    return 'Critical';
  }

  InspectionEntity copyWith({
    String? id,
    String? fieldId,
    String? farmId,
    DateTime? date,
    String? notes,
    double? healthScore,
    List<InspectionIssue>? issues,
    String? status,
  }) {
    return InspectionEntity(
      id: id ?? this.id,
      fieldId: fieldId ?? this.fieldId,
      farmId: farmId ?? this.farmId,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      healthScore: healthScore ?? this.healthScore,
      issues: issues ?? this.issues,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props =>
      [id, fieldId, farmId, date, notes, healthScore, issues, status];
}
