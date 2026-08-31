import 'package:equatable/equatable.dart';

import '../../domain/entities/task_entity.dart';

/// States for the task management BLoC.
sealed class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {
  const TaskInitial();
}

class TaskLoading extends TaskState {
  const TaskLoading();
}

class TasksLoaded extends TaskState {
  const TasksLoaded({
    required this.tasks,
    this.filteredTasks,
    this.activeStatusFilter,
    this.activeTypeFilter,
    this.searchQuery,
  });

  /// All tasks from the repository.
  final List<FarmTask> tasks;

  /// Tasks after client-side filtering (null = no filter).
  final List<FarmTask>? filteredTasks;

  final TaskStatus? activeStatusFilter;
  final TaskType? activeTypeFilter;
  final String? searchQuery;

  List<FarmTask> get displayTasks => filteredTasks ?? tasks;

  int get pendingCount =>
      tasks.where((t) => t.status == TaskStatus.pending).length;
  int get inProgressCount =>
      tasks.where((t) => t.status == TaskStatus.inProgress).length;
  int get completedCount =>
      tasks.where((t) => t.status == TaskStatus.completed).length;
  int get overdueCount => tasks.where((t) => t.isOverdue).length;

  @override
  List<Object?> get props => [
        tasks,
        filteredTasks,
        activeStatusFilter,
        activeTypeFilter,
        searchQuery,
      ];
}

class TaskCreated extends TaskState {
  const TaskCreated(this.task);

  final FarmTask task;

  @override
  List<Object?> get props => [task];
}

class TaskUpdated extends TaskState {
  const TaskUpdated(this.task);

  final FarmTask task;

  @override
  List<Object?> get props => [task];
}

class TaskError extends TaskState {
  const TaskError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
