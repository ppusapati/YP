import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

/// Marks a task as completed.
class CompleteTaskUseCase {
  const CompleteTaskUseCase(this._repository);

  final TaskRepository _repository;

  Future<FarmTask> call(String taskId) {
    return _repository.completeTask(taskId);
  }
}
