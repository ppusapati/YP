import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/task_model.dart';

/// Local cache for farm tasks.
abstract class TaskLocalDataSource {
  Future<List<TaskModel>> getCachedTasks();
  Future<void> cacheTasks(List<TaskModel> tasks);
  Future<void> cacheTask(TaskModel task);
  Future<void> removeTask(String taskId);
  Future<void> clearCache();
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  TaskLocalDataSourceImpl({required SharedPreferences sharedPreferences})
      : _prefs = sharedPreferences;

  final SharedPreferences _prefs;
  static final _log = Logger('TaskLocalDataSource');

  static const _tasksKey = 'farm_tasks_cache';
  static const _cacheTimeKey = 'farm_tasks_cache_time';
  static const _cacheDuration = Duration(minutes: 30);

  @override
  Future<List<TaskModel>> getCachedTasks() async {
    try {
      if (!_isCacheValid()) return [];
      final jsonString = _prefs.getString(_tasksKey);
      if (jsonString == null) return [];

      final list = jsonDecode(jsonString) as List<dynamic>;
      return list
          .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _log.warning('Failed to read cached tasks: $e');
      return [];
    }
  }

  @override
  Future<void> cacheTasks(List<TaskModel> tasks) async {
    try {
      final jsonString = jsonEncode(tasks.map((t) => t.toJson()).toList());
      await _prefs.setString(_tasksKey, jsonString);
      await _prefs.setInt(_cacheTimeKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      _log.warning('Failed to cache tasks: $e');
    }
  }

  @override
  Future<void> cacheTask(TaskModel task) async {
    final tasks = await getCachedTasks();
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index >= 0) {
      tasks[index] = task;
    } else {
      tasks.add(task);
    }
    await cacheTasks(tasks);
  }

  @override
  Future<void> removeTask(String taskId) async {
    final tasks = await getCachedTasks();
    tasks.removeWhere((t) => t.id == taskId);
    await cacheTasks(tasks);
  }

  @override
  Future<void> clearCache() async {
    await _prefs.remove(_tasksKey);
    await _prefs.remove(_cacheTimeKey);
  }

  bool _isCacheValid() {
    final cachedTime = _prefs.getInt(_cacheTimeKey);
    if (cachedTime == null) return false;
    final cacheDate = DateTime.fromMillisecondsSinceEpoch(cachedTime);
    return DateTime.now().difference(cacheDate) < _cacheDuration;
  }
}
