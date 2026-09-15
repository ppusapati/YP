import '../generated/task.pb.dart' as task_pb;
import 'base_service.dart';

/// ConnectRPC service client for farm task management.
class TaskServiceClient extends BaseService {
  TaskServiceClient({
    required super.baseUrl,
    super.httpClient,
    super.interceptors,
  });

  @override
  String get serviceName => 'agriculture.task.v1.TaskService';

  /// Retrieves a single task by ID.
  Future<task_pb.GetTaskResponse> getTask(String taskId) async {
    final request = task_pb.GetTaskRequest(id: taskId);
    final bytes = await callUnary('GetTask', request);
    return task_pb.GetTaskResponse.fromBuffer(bytes);
  }

  /// Lists tasks, optionally filtered by farm ID.
  Future<task_pb.ListTasksResponse> listTasks({
    String? farmId,
    String? fieldId,
    String? assignedTo,
    task_pb.TaskStatus? status,
    task_pb.TaskPriority? priority,
    int? pageSize,
    String? pageToken,
  }) async {
    final request = task_pb.ListTasksRequest();
    if (farmId != null) request.farmId = farmId;
    if (fieldId != null) request.fieldId = fieldId;
    if (assignedTo != null) request.assignedTo = assignedTo;
    if (status != null) request.status = status;
    if (priority != null) request.priority = priority;
    if (pageSize != null) request.pageSize = pageSize;
    if (pageToken != null) request.pageToken = pageToken;
    final bytes = await callUnary('ListTasks', request);
    return task_pb.ListTasksResponse.fromBuffer(bytes);
  }

  /// Creates a new task.
  Future<task_pb.CreateTaskResponse> createTask(
      task_pb.CreateTaskRequest request) async {
    final bytes = await callUnary('CreateTask', request);
    return task_pb.CreateTaskResponse.fromBuffer(bytes);
  }

  /// Updates an existing task.
  Future<task_pb.UpdateTaskResponse> updateTask(
      task_pb.UpdateTaskRequest request) async {
    final bytes = await callUnary('UpdateTask', request);
    return task_pb.UpdateTaskResponse.fromBuffer(bytes);
  }

  /// Deletes a task by ID.
  Future<task_pb.DeleteTaskResponse> deleteTask(String taskId) async {
    final request = task_pb.DeleteTaskRequest(id: taskId);
    final bytes = await callUnary('DeleteTask', request);
    return task_pb.DeleteTaskResponse.fromBuffer(bytes);
  }
}
