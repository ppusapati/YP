import 'package:flutter_network/flutter_network.dart';
import 'package:logging/logging.dart';

import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_datasource.dart';
import '../datasources/task_remote_datasource.dart';
import '../models/task_model.dart';

/// Concrete [TaskRepository] with remote-first, local-fallback strategy.
class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl({
    required TaskRemoteDataSource remoteDataSource,
    required TaskLocalDataSource localDataSource,
  })  : _remote = remoteDataSource,
        _local = localDataSource;

  final TaskRemoteDataSource _remote;
  final TaskLocalDataSource _local;
  static final _log = Logger('TaskRepositoryImpl');

  @override
  Future<List<FarmTask>> getTasks({
    String? farmId,
    TaskStatus? status,
    TaskType? taskType,
  }) async {
    try {
      final tasks = await _remote.fetchTasks(
        farmId: farmId,
        status: status,
        taskType: taskType,
      );
      await _local.cacheTasks(tasks);
      return tasks;
    } on ConnectException catch (e) {
      _log.warning('Remote fetch failed, using cache: $e');
      return _local.getCachedTasks();
    }
  }

  @override
  Future<FarmTask> getTaskById(String taskId) async {
    return _remote.fetchTaskById(taskId);
  }

  @override
  Future<FarmTask> createTask(FarmTask task) async {
    final model = TaskModel.fromEntity(task);
    final created = await _remote.createTask(model);
    await _local.cacheTask(created);
    return created;
  }

  @override
  Future<FarmTask> updateTask(FarmTask task) async {
    final model = TaskModel.fromEntity(task);
    final updated = await _remote.updateTask(model);
    await _local.cacheTask(updated);
    return updated;
  }

  @override
  Future<FarmTask> completeTask(String taskId) async {
    final completed = await _remote.completeTask(taskId);
    await _local.cacheTask(completed);
    return completed;
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await _remote.deleteTask(taskId);
    await _local.removeTask(taskId);
  }
}
