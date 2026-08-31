import '../../domain/entities/inspection_entity.dart';

/// Data model for InspectionEntity with JSON serialization.
class InspectionModel {
  final String id;
  final String fieldId;
  final String farmId;
  final DateTime date;
  final String notes;
  final double healthScore;
  final List<InspectionIssueModel> issues;
  final String status;

  const InspectionModel({
    required this.id,
    required this.fieldId,
    required this.farmId,
    required this.date,
    this.notes = '',
    required this.healthScore,
    this.issues = const [],
    this.status = 'draft',
  });

  factory InspectionModel.fromJson(Map<String, dynamic> json) {
    return InspectionModel(
      id: json['id'] as String,
      fieldId: json['field_id'] as String,
      farmId: json['farm_id'] as String,
      date: DateTime.parse(json['date'] as String),
      notes: json['notes'] as String? ?? '',
      healthScore: (json['health_score'] as num).toDouble(),
      issues: (json['issues'] as List<dynamic>?)
              ?.map((e) =>
                  InspectionIssueModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      status: json['status'] as String? ?? 'draft',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'field_id': fieldId,
      'farm_id': farmId,
      'date': date.toIso8601String(),
      'notes': notes,
      'health_score': healthScore,
      'issues': issues.map((e) => e.toJson()).toList(),
      'status': status,
    };
  }

  InspectionEntity toEntity() {
    return InspectionEntity(
      id: id,
      fieldId: fieldId,
      farmId: farmId,
      date: date,
      notes: notes,
      healthScore: healthScore,
      issues: issues.map((e) => e.toEntity()).toList(),
      status: status,
    );
  }

  factory InspectionModel.fromEntity(InspectionEntity entity) {
    return InspectionModel(
      id: entity.id,
      fieldId: entity.fieldId,
      farmId: entity.farmId,
      date: entity.date,
      notes: entity.notes,
      healthScore: entity.healthScore,
      issues: entity.issues
          .map((e) => InspectionIssueModel.fromEntity(e))
          .toList(),
      status: entity.status,
    );
  }
}

class InspectionIssueModel {
  final String description;
  final String severity;
  final String? photoUrl;

  const InspectionIssueModel({
    required this.description,
    required this.severity,
    this.photoUrl,
  });

  factory InspectionIssueModel.fromJson(Map<String, dynamic> json) {
    return InspectionIssueModel(
      description: json['description'] as String,
      severity: json['severity'] as String,
      photoUrl: json['photo_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'severity': severity,
      if (photoUrl != null) 'photo_url': photoUrl,
    };
  }

  InspectionIssue toEntity() {
    return InspectionIssue(
      description: description,
      severity: IssueSeverity.values.firstWhere(
        (e) => e.name == severity,
        orElse: () => IssueSeverity.low,
      ),
      photoUrl: photoUrl,
    );
  }

  factory InspectionIssueModel.fromEntity(InspectionIssue entity) {
    return InspectionIssueModel(
      description: entity.description,
      severity: entity.severity.name,
      photoUrl: entity.photoUrl,
    );
  }
}
