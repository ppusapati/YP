import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

/// The type of farm task.
enum TaskType {
  spraying,
  fertilizer,
  irrigation,
  harvesting,
  scouting,
  planting,
  soilPrep,
  maintenance,
  other;

  String get label => switch (this) {
        spraying => 'Spraying',
        fertilizer => 'Fertilizer',
        irrigation => 'Irrigation',
        harvesting => 'Harvesting',
        scouting => 'Scouting',
        planting => 'Planting',
        soilPrep => 'Soil Prep',
        maintenance => 'Maintenance',
        other => 'Other',
      };
}

/// The current status of a farm task.
enum TaskStatus {
  pending,
  inProgress,
  completed,
  cancelled;

  String get label => switch (this) {
        pending => 'Pending',
        inProgress => 'In Progress',
        completed => 'Completed',
        cancelled => 'Cancelled',
      };
}

/// Priority levels for farm tasks.
enum TaskPriority {
  low,
  medium,
  high,
  urgent;

  String get label => switch (this) {
        low => 'Low',
        medium => 'Medium',
        high => 'High',
        urgent => 'Urgent',
      };
}

/// Represents a task associated with a farm field.
class FarmTask extends Equatable {
  const FarmTask({
    required this.id,
    required this.farmId,
    required this.fieldId,
    required this.title,
    required this.description,
    required this.taskType,
    required this.status,
    required this.priority,
    required this.dueDate,
    this.location,
    this.assignee,
    this.completedDate,
    this.createdAt,
  });

  final String id;
  final String farmId;
  final String fieldId;
  final String title;
  final String description;
  final TaskType taskType;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime dueDate;
  final LatLng? location;
  final String? assignee;
  final DateTime? completedDate;
  final DateTime? createdAt;

  /// Whether the task is past its due date and not yet completed.
  bool get isOverdue =>
      status != TaskStatus.completed &&
      status != TaskStatus.cancelled &&
      dueDate.isBefore(DateTime.now());

  FarmTask copyWith({
    String? id,
    String? farmId,
    String? fieldId,
    String? title,
    String? description,
    TaskType? taskType,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? dueDate,
    LatLng? location,
    String? assignee,
    DateTime? completedDate,
    DateTime? createdAt,
  }) {
    return FarmTask(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      fieldId: fieldId ?? this.fieldId,
      title: title ?? this.title,
      description: description ?? this.description,
      taskType: taskType ?? this.taskType,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      location: location ?? this.location,
      assignee: assignee ?? this.assignee,
      completedDate: completedDate ?? this.completedDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        farmId,
        fieldId,
        title,
        description,
        taskType,
        status,
        priority,
        dueDate,
        location,
        assignee,
        completedDate,
        createdAt,
      ];
}
