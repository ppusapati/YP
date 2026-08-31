import 'package:equatable/equatable.dart';

import '../../domain/entities/task_entity.dart';

/// Events for the task management BLoC.
sealed class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

/// Load all tasks with optional filters.
class LoadTasks extends TaskEvent {
  const LoadTasks({this.farmId, this.status, this.taskType});

  final String? farmId;
  final TaskStatus? status;
  final TaskType? taskType;

  @override
  List<Object?> get props => [farmId, status, taskType];
}

/// Create a new task.
class CreateTask extends TaskEvent {
  const CreateTask(this.task);

  final FarmTask task;

  @override
  List<Object?> get props => [task];
}

/// Update an existing task.
class UpdateTask extends TaskEvent {
  const UpdateTask(this.task);

  final FarmTask task;

  @override
  List<Object?> get props => [task];
}

/// Mark a task as completed.
class CompleteTask extends TaskEvent {
  const CompleteTask(this.taskId);

  final String taskId;

  @override
  List<Object?> get props => [taskId];
}

/// Delete a task.
class DeleteTask extends TaskEvent {
  const DeleteTask(this.taskId);

  final String taskId;

  @override
  List<Object?> get props => [taskId];
}

/// Apply client-side filters to the loaded tasks.
class FilterTasks extends TaskEvent {
  const FilterTasks({this.status, this.taskType, this.searchQuery});

  final TaskStatus? status;
  final TaskType? taskType;
  final String? searchQuery;

  @override
  List<Object?> get props => [status, taskType, searchQuery];
}
