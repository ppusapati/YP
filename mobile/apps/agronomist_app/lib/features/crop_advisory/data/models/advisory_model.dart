import '../../domain/entities/advisory_entity.dart';

/// Data model for AdvisoryEntity with JSON serialization.
class AdvisoryModel {
  final String id;
  final String farmId;
  final String fieldId;
  final String cropName;
  final String recommendation;
  final DateTime plantingDate;
  final String priority;
  final DateTime createdAt;

  const AdvisoryModel({
    required this.id,
    required this.farmId,
    required this.fieldId,
    required this.cropName,
    required this.recommendation,
    required this.plantingDate,
    this.priority = 'normal',
    required this.createdAt,
  });

  factory AdvisoryModel.fromJson(Map<String, dynamic> json) {
    return AdvisoryModel(
      id: json['id'] as String,
      farmId: json['farm_id'] as String,
      fieldId: json['field_id'] as String,
      cropName: json['crop_name'] as String,
      recommendation: json['recommendation'] as String,
      plantingDate: DateTime.parse(json['planting_date'] as String),
      priority: json['priority'] as String? ?? 'normal',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farm_id': farmId,
      'field_id': fieldId,
      'crop_name': cropName,
      'recommendation': recommendation,
      'planting_date': plantingDate.toIso8601String(),
      'priority': priority,
      'created_at': createdAt.toIso8601String(),
    };
  }

  AdvisoryEntity toEntity() {
    return AdvisoryEntity(
      id: id,
      farmId: farmId,
      fieldId: fieldId,
      cropName: cropName,
      recommendation: recommendation,
      plantingDate: plantingDate,
      priority: priority,
      createdAt: createdAt,
    );
  }

  factory AdvisoryModel.fromEntity(AdvisoryEntity entity) {
    return AdvisoryModel(
      id: entity.id,
      farmId: entity.farmId,
      fieldId: entity.fieldId,
      cropName: entity.cropName,
      recommendation: entity.recommendation,
      plantingDate: entity.plantingDate,
      priority: entity.priority,
      createdAt: entity.createdAt,
    );
  }
}
