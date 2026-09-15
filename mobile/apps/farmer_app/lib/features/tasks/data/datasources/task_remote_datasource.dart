import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:flutter_network/flutter_network.dart';
import 'package:flutter_proto/src/generated/task.pb.dart' as task_pb;
import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart'
    as ts;

import '../../domain/entities/task_entity.dart';
import '../models/task_model.dart';

/// Remote data source for farm tasks via ConnectRPC.
abstract class TaskRemoteDataSource {
  Future<List<TaskModel>> fetchTasks({
    String? farmId,
    TaskStatus? status,
    TaskType? taskType,
  });
  Future<TaskModel> fetchTaskById(String taskId);
  Future<TaskModel> createTask(TaskModel task);
  Future<TaskModel> updateTask(TaskModel task);
  Future<TaskModel> completeTask(String taskId);
  Future<void> deleteTask(String taskId);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  TaskRemoteDataSourceImpl({required ConnectClient client}) : _client = client;

  final ConnectClient _client;

  static const _basePath = '/agriculture.task.v1.TaskService';

  Future<ConnectResponse> _call(
      String method, $pb.GeneratedMessage request) async {
    final response = await _client.unary(
      '$_basePath/$method',
      body: request.writeToBuffer(),
    );
    if (!response.isSuccess) {
      throw TaskRemoteException(
        'RPC call $_basePath/$method failed',
        statusCode: response.statusCode,
      );
    }
    return response;
  }

  @override
  Future<List<TaskModel>> fetchTasks({
    String? farmId,
    TaskStatus? status,
    TaskType? taskType,
  }) async {
    final request = task_pb.ListTasksRequest();
    if (farmId != null) request.farmId = farmId;
    if (status != null) request.status = _statusToPb(status);
    final response = await _call('ListTasks', request);
    final result = task_pb.ListTasksResponse.fromBuffer(response.body);
    return result.tasks.map(_taskFromPb).toList();
  }

  @override
  Future<TaskModel> fetchTaskById(String taskId) async {
    final request = task_pb.GetTaskRequest(id: taskId);
    final response = await _call('GetTask', request);
    final result = task_pb.GetTaskResponse.fromBuffer(response.body);
    return _taskFromPb(result.task);
  }

  @override
  Future<TaskModel> createTask(TaskModel task) async {
    final request = task_pb.CreateTaskRequest(
      title: task.title,
      description: task.description,
      priority: _priorityToPb(task.priority),
      farmId: task.farmId,
      fieldId: task.fieldId,
    );
    if (task.assignee != null) request.assignedTo = task.assignee!;
    final epochSeconds = task.dueDate.millisecondsSinceEpoch ~/ 1000;
    request.dueDate = ts.Timestamp(seconds: fixnum.Int64(epochSeconds));

    final response = await _call('CreateTask', request);
    final result = task_pb.CreateTaskResponse.fromBuffer(response.body);
    return _taskFromPb(result.task);
  }

  @override
  Future<TaskModel> updateTask(TaskModel task) async {
    final request = task_pb.UpdateTaskRequest(
      id: task.id,
      title: task.title,
      description: task.description,
      status: _statusToPb(task.status),
      priority: _priorityToPb(task.priority),
      fieldId: task.fieldId,
    );
    if (task.assignee != null) request.assignedTo = task.assignee!;
    final epochSeconds = task.dueDate.millisecondsSinceEpoch ~/ 1000;
    request.dueDate = ts.Timestamp(seconds: fixnum.Int64(epochSeconds));

    final response = await _call('UpdateTask', request);
    final result = task_pb.UpdateTaskResponse.fromBuffer(response.body);
    return _taskFromPb(result.task);
  }

  @override
  Future<TaskModel> completeTask(String taskId) async {
    final request = task_pb.UpdateTaskRequest(
      id: taskId,
      status: task_pb.TaskStatus.TASK_STATUS_COMPLETED,
    );
    final response = await _call('UpdateTask', request);
    final result = task_pb.UpdateTaskResponse.fromBuffer(response.body);
    return _taskFromPb(result.task);
  }

  @override
  Future<void> deleteTask(String taskId) async {
    final request = task_pb.DeleteTaskRequest(id: taskId);
    await _call('DeleteTask', request);
  }

  // -- Proto <-> domain mapping helpers --

  static task_pb.TaskStatus _statusToPb(TaskStatus status) => switch (status) {
        TaskStatus.pending => task_pb.TaskStatus.TASK_STATUS_PENDING,
        TaskStatus.inProgress => task_pb.TaskStatus.TASK_STATUS_IN_PROGRESS,
        TaskStatus.completed => task_pb.TaskStatus.TASK_STATUS_COMPLETED,
        TaskStatus.cancelled => task_pb.TaskStatus.TASK_STATUS_CANCELLED,
      };

  static TaskStatus _statusFromPb(task_pb.TaskStatus status) =>
      switch (status) {
        task_pb.TaskStatus.TASK_STATUS_PENDING => TaskStatus.pending,
        task_pb.TaskStatus.TASK_STATUS_IN_PROGRESS => TaskStatus.inProgress,
        task_pb.TaskStatus.TASK_STATUS_COMPLETED => TaskStatus.completed,
        task_pb.TaskStatus.TASK_STATUS_CANCELLED => TaskStatus.cancelled,
        _ => TaskStatus.pending,
      };

  static task_pb.TaskPriority _priorityToPb(TaskPriority priority) =>
      switch (priority) {
        TaskPriority.low => task_pb.TaskPriority.TASK_PRIORITY_LOW,
        TaskPriority.medium => task_pb.TaskPriority.TASK_PRIORITY_MEDIUM,
        TaskPriority.high => task_pb.TaskPriority.TASK_PRIORITY_HIGH,
        TaskPriority.urgent => task_pb.TaskPriority.TASK_PRIORITY_URGENT,
      };

  static TaskPriority _priorityFromPb(task_pb.TaskPriority priority) =>
      switch (priority) {
        task_pb.TaskPriority.TASK_PRIORITY_LOW => TaskPriority.low,
        task_pb.TaskPriority.TASK_PRIORITY_MEDIUM => TaskPriority.medium,
        task_pb.TaskPriority.TASK_PRIORITY_HIGH => TaskPriority.high,
        task_pb.TaskPriority.TASK_PRIORITY_URGENT => TaskPriority.urgent,
        _ => TaskPriority.medium,
      };

  static TaskModel _taskFromPb(task_pb.Task task) {
    return TaskModel(
      id: task.id,
      farmId: task.farmId,
      fieldId: task.fieldId,
      title: task.title,
      description: task.description,
      taskType: TaskType.other,
      status: _statusFromPb(task.status),
      priority: _priorityFromPb(task.priority),
      dueDate: task.hasDueDate()
          ? DateTime.fromMillisecondsSinceEpoch(
              task.dueDate.seconds.toInt() * 1000)
          : DateTime.now(),
      assignee: task.hasAssignedTo() ? task.assignedTo : null,
      completedDate:
          task.status == task_pb.TaskStatus.TASK_STATUS_COMPLETED &&
                  task.hasUpdatedAt()
              ? DateTime.fromMillisecondsSinceEpoch(
                  task.updatedAt.seconds.toInt() * 1000)
              : null,
      createdAt: task.hasCreatedAt()
          ? DateTime.fromMillisecondsSinceEpoch(
              task.createdAt.seconds.toInt() * 1000)
          : null,
    );
  }
}

class TaskRemoteException implements Exception {
  final String message;
  final int? statusCode;

  const TaskRemoteException(this.message, {this.statusCode});

  @override
  String toString() =>
      'TaskRemoteException($message, statusCode: $statusCode)';
}
