import 'package:http/http.dart' as http;

import '../generated/task.pb.dart';
import 'base_service.dart';

/// ConnectRPC service client for farm task management.
///
/// Provides CRUD operations for tasks, status updates,
/// and assignment management.
class TaskServiceClient extends BaseService {
  TaskServiceClient({
    required super.baseUrl,
    super.httpClient,
    super.interceptors,
  });

  @override
  String get serviceName => 'yieldpoint.task.v1.TaskService';

  /// Retrieves a task by its unique identifier.
  Future<FarmTask> getTask(String taskId) async {
    final request = FarmTask(id: taskId);
    final bytes = await callUnary('GetTask', request);
    return FarmTask.fromBuffer(bytes);
  }

  /// Lists tasks for a farm with optional status filter.
  Future<List<FarmTask>> listTasks({
    required String farmId,
    TaskStatus? status,
    TaskType? taskType,
    String? assignee,
    int pageSize = 20,
  }) async {
    final request = FarmTask(
      farmId: farmId,
      status: status,
      taskType: taskType,
      assignee: assignee,
    );
    final bytes = await callUnary('ListTasks', request);
    final task = FarmTask.fromBuffer(bytes);
    return [task];
  }

  /// Creates a new farm task.
  Future<FarmTask> createTask(FarmTask task) async {
    final bytes = await callUnary('CreateTask', task);
    return FarmTask.fromBuffer(bytes);
  }

  /// Updates an existing task.
  Future<FarmTask> updateTask(FarmTask task) async {
    final bytes = await callUnary('UpdateTask', task);
    return FarmTask.fromBuffer(bytes);
  }

  /// Deletes a task by ID.
  Future<void> deleteTask(String taskId) async {
    final request = FarmTask(id: taskId);
    await callUnary('DeleteTask', request);
  }

  /// Updates only the status of a task.
  Future<FarmTask> updateTaskStatus({
    required String taskId,
    required TaskStatus status,
  }) async {
    final request = FarmTask(id: taskId, status: status);
    final bytes = await callUnary('UpdateTaskStatus', request);
    return FarmTask.fromBuffer(bytes);
  }

  /// Assigns a task to a user.
  Future<FarmTask> assignTask({
    required String taskId,
    required String assignee,
  }) async {
    final request = FarmTask(id: taskId, assignee: assignee);
    final bytes = await callUnary('AssignTask', request);
    return FarmTask.fromBuffer(bytes);
  }

  /// Streams real-time task updates for a farm.
  Stream<FarmTask> streamTaskUpdates(String farmId) {
    final request = FarmTask(farmId: farmId);
    return callServerStream('StreamTaskUpdates', request)
        .map((bytes) => FarmTask.fromBuffer(bytes));
  }
}
