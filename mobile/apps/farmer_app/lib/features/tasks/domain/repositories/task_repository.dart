import '../entities/task_entity.dart';

/// Contract for task data access.
abstract class TaskRepository {
  /// Returns tasks, optionally filtered by [farmId], [status], or [taskType].
  Future<List<FarmTask>> getTasks({
    String? farmId,
    TaskStatus? status,
    TaskType? taskType,
  });

  /// Returns a single task by [taskId].
  Future<FarmTask> getTaskById(String taskId);

  /// Creates a new task and returns the created entity.
  Future<FarmTask> createTask(FarmTask task);

  /// Updates an existing task and returns the updated entity.
  Future<FarmTask> updateTask(FarmTask task);

  /// Marks [taskId] as completed with the current timestamp.
  Future<FarmTask> completeTask(String taskId);

  /// Deletes the task with [taskId].
  Future<void> deleteTask(String taskId);
}
