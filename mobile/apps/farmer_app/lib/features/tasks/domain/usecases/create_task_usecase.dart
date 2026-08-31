import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

/// Creates a new farm task.
class CreateTaskUseCase {
  const CreateTaskUseCase(this._repository);

  final TaskRepository _repository;

  Future<FarmTask> call(FarmTask task) {
    return _repository.createTask(task);
  }
}
