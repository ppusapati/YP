import 'base_service.dart';

/// ConnectRPC service client for farm task management.
///
/// NOTE: No generated protobuf file exists for the task service
/// (no task.proto definition). This service client is a placeholder
/// until the task proto is defined and code-generated.
class TaskServiceClient extends BaseService {
  TaskServiceClient({
    required super.baseUrl,
    super.httpClient,
    super.interceptors,
  });

  @override
  String get serviceName => 'agriculture.task.v1.TaskService';

  /// Not implemented - no task.pb.dart generated file exists.
  Future<void> getTask(String taskId) async {
    throw UnimplementedError(
      'TaskService is not yet available: no task.proto has been defined.',
    );
  }

  /// Not implemented - no task.pb.dart generated file exists.
  Future<void> listTasks({required String farmId}) async {
    throw UnimplementedError(
      'TaskService is not yet available: no task.proto has been defined.',
    );
  }

  /// Not implemented - no task.pb.dart generated file exists.
  Future<void> createTask() async {
    throw UnimplementedError(
      'TaskService is not yet available: no task.proto has been defined.',
    );
  }

  /// Not implemented - no task.pb.dart generated file exists.
  Future<void> updateTask() async {
    throw UnimplementedError(
      'TaskService is not yet available: no task.proto has been defined.',
    );
  }

  /// Not implemented - no task.pb.dart generated file exists.
  Future<void> deleteTask(String taskId) async {
    throw UnimplementedError(
      'TaskService is not yet available: no task.proto has been defined.',
    );
  }
}
