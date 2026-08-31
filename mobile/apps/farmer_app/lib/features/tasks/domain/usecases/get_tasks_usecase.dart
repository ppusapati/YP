import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

/// Retrieves farm tasks with optional filters.
class GetTasksUseCase {
  const GetTasksUseCase(this._repository);

  final TaskRepository _repository;

  Future<List<FarmTask>> call({
    String? farmId,
    TaskStatus? status,
    TaskType? taskType,
  }) {
    return _repository.getTasks(
      farmId: farmId,
      status: status,
      taskType: taskType,
    );
  }
}
