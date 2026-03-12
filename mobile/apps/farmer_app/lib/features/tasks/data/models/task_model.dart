import 'package:latlong2/latlong.dart';

import '../../domain/entities/task_entity.dart';

/// Data transfer model for [FarmTask], handles JSON serialization.
class TaskModel extends FarmTask {
  const TaskModel({
    required super.id,
    required super.farmId,
    required super.fieldId,
    required super.title,
    required super.description,
    required super.taskType,
    required super.status,
    required super.priority,
    required super.dueDate,
    super.location,
    super.assignee,
    super.completedDate,
    super.createdAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      farmId: json['farm_id'] as String,
      fieldId: json['field_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      taskType: _parseTaskType(json['task_type'] as String),
      status: _parseTaskStatus(json['status'] as String),
      priority: _parseTaskPriority(json['priority'] as String),
      dueDate: DateTime.parse(json['due_date'] as String),
      location: json['location'] != null
          ? LatLng(
              (json['location']['lat'] as num).toDouble(),
              (json['location']['lng'] as num).toDouble(),
            )
          : null,
      assignee: json['assignee'] as String?,
      completedDate: json['completed_date'] != null
          ? DateTime.parse(json['completed_date'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  factory TaskModel.fromEntity(FarmTask entity) {
    return TaskModel(
      id: entity.id,
      farmId: entity.farmId,
      fieldId: entity.fieldId,
      title: entity.title,
      description: entity.description,
      taskType: entity.taskType,
      status: entity.status,
      priority: entity.priority,
      dueDate: entity.dueDate,
      location: entity.location,
      assignee: entity.assignee,
      completedDate: entity.completedDate,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'farm_id': farmId,
        'field_id': fieldId,
        'title': title,
        'description': description,
        'task_type': taskType.name,
        'status': _statusToString(status),
        'priority': priority.name,
        'due_date': dueDate.toIso8601String(),
        if (location != null)
          'location': {
            'lat': location!.latitude,
            'lng': location!.longitude,
          },
        if (assignee != null) 'assignee': assignee,
        if (completedDate != null)
          'completed_date': completedDate!.toIso8601String(),
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      };

  static TaskType _parseTaskType(String value) => switch (value) {
        'spraying' => TaskType.spraying,
        'fertilizer' => TaskType.fertilizer,
        'irrigation' => TaskType.irrigation,
        'harvesting' => TaskType.harvesting,
        'scouting' => TaskType.scouting,
        'planting' => TaskType.planting,
        'soilPrep' || 'soil_prep' => TaskType.soilPrep,
        'maintenance' => TaskType.maintenance,
        _ => TaskType.other,
      };

  static TaskStatus _parseTaskStatus(String value) => switch (value) {
        'pending' => TaskStatus.pending,
        'in_progress' || 'inProgress' => TaskStatus.inProgress,
        'completed' => TaskStatus.completed,
        'cancelled' => TaskStatus.cancelled,
        _ => TaskStatus.pending,
      };

  static TaskPriority _parseTaskPriority(String value) => switch (value) {
        'low' => TaskPriority.low,
        'medium' => TaskPriority.medium,
        'high' => TaskPriority.high,
        'urgent' => TaskPriority.urgent,
        _ => TaskPriority.medium,
      };

  static String _statusToString(TaskStatus status) => switch (status) {
        TaskStatus.pending => 'pending',
        TaskStatus.inProgress => 'in_progress',
        TaskStatus.completed => 'completed',
        TaskStatus.cancelled => 'cancelled',
      };
}
