import 'package:equatable/equatable.dart';

/// Represents a crop advisory recommendation for a field.
class AdvisoryEntity extends Equatable {
  final String id;
  final String farmId;
  final String fieldId;
  final String cropName;
  final String recommendation;
  final DateTime plantingDate;
  final String priority;
  final DateTime createdAt;

  const AdvisoryEntity({
    required this.id,
    required this.farmId,
    required this.fieldId,
    required this.cropName,
    required this.recommendation,
    required this.plantingDate,
    this.priority = 'normal',
    required this.createdAt,
  });

  bool get isHighPriority => priority == 'high' || priority == 'critical';

  AdvisoryEntity copyWith({
    String? id,
    String? farmId,
    String? fieldId,
    String? cropName,
    String? recommendation,
    DateTime? plantingDate,
    String? priority,
    DateTime? createdAt,
  }) {
    return AdvisoryEntity(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      fieldId: fieldId ?? this.fieldId,
      cropName: cropName ?? this.cropName,
      recommendation: recommendation ?? this.recommendation,
      plantingDate: plantingDate ?? this.plantingDate,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, farmId, fieldId, cropName, recommendation, plantingDate, priority, createdAt];
}
