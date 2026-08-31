import 'dart:convert';

import 'package:flutter_network/flutter_network.dart';
import 'package:logging/logging.dart';

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
  static final _log = Logger('TaskRemoteDataSource');

  static const _basePath = '/yieldpoint.task.v1.TaskService';

  @override
  Future<List<TaskModel>> fetchTasks({
    String? farmId,
    TaskStatus? status,
    TaskType? taskType,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (farmId != null) params['farm_id'] = farmId;
      if (status != null) params['status'] = status.name;
      if (taskType != null) params['task_type'] = taskType.name;

      final body = params.isNotEmpty
          ? utf8.encode(jsonEncode(params)) as dynamic
          : null;

      final response = await _client.unary('$_basePath/GetTasks', body: body);
      final data = jsonDecode(utf8.decode(response.body)) as Map<String, dynamic>;
      final tasks = (data['tasks'] as List<dynamic>?) ?? [];

      return tasks
          .map((t) => TaskModel.fromJson(t as Map<String, dynamic>))
          .toList();
    } on ConnectException catch (e) {
      _log.severe('Failed to fetch tasks: $e');
      rethrow;
    }
  }

  @override
  Future<TaskModel> fetchTaskById(String taskId) async {
    try {
      final body = utf8.encode(jsonEncode({'task_id': taskId}));
      final response = await _client.unary(
        '$_basePath/GetTask',
        body: body as dynamic,
      );
      final data = jsonDecode(utf8.decode(response.body)) as Map<String, dynamic>;
      return TaskModel.fromJson(data);
    } on ConnectException catch (e) {
      _log.severe('Failed to fetch task $taskId: $e');
      rethrow;
    }
  }

  @override
  Future<TaskModel> createTask(TaskModel task) async {
    try {
      final body = utf8.encode(jsonEncode(task.toJson()));
      final response = await _client.unary(
        '$_basePath/CreateTask',
        body: body as dynamic,
      );
      final data = jsonDecode(utf8.decode(response.body)) as Map<String, dynamic>;
      return TaskModel.fromJson(data);
    } on ConnectException catch (e) {
      _log.severe('Failed to create task: $e');
      rethrow;
    }
  }

  @override
  Future<TaskModel> updateTask(TaskModel task) async {
    try {
      final body = utf8.encode(jsonEncode(task.toJson()));
      final response = await _client.unary(
        '$_basePath/UpdateTask',
        body: body as dynamic,
      );
      final data = jsonDecode(utf8.decode(response.body)) as Map<String, dynamic>;
      return TaskModel.fromJson(data);
    } on ConnectException catch (e) {
      _log.severe('Failed to update task: $e');
      rethrow;
    }
  }

  @override
  Future<TaskModel> completeTask(String taskId) async {
    try {
      final body = utf8.encode(jsonEncode({'task_id': taskId}));
      final response = await _client.unary(
        '$_basePath/CompleteTask',
        body: body as dynamic,
      );
      final data = jsonDecode(utf8.decode(response.body)) as Map<String, dynamic>;
      return TaskModel.fromJson(data);
    } on ConnectException catch (e) {
      _log.severe('Failed to complete task: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    try {
      final body = utf8.encode(jsonEncode({'task_id': taskId}));
      await _client.unary('$_basePath/DeleteTask', body: body as dynamic);
    } on ConnectException catch (e) {
      _log.severe('Failed to delete task: $e');
      rethrow;
    }
  }
}
