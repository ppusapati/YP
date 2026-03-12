import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

/// Updates an existing farm task.
class UpdateTaskUseCase {
  const UpdateTaskUseCase(this._repository);

  final TaskRepository _repository;

  Future<FarmTask> call(FarmTask task) {
    return _repository.updateTask(task);
  }
}
