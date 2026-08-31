import 'package:drift/drift.dart';

import '../database/app_database.dart';

part 'task_dao.g.dart';

/// Data access object for farm task records.
///
/// Provides CRUD operations, status filtering, and assignment queries.
@DriftAccessor(tables: [Tasks])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  TaskDao(super.db);

  /// Retrieves all tasks ordered by due date.
  Future<List<Task>> getAllTasks() {
    return (select(tasks)..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
        .get();
  }

  /// Watches all tasks.
  Stream<List<Task>> watchAllTasks() {
    return (select(tasks)..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
        .watch();
  }

  /// Retrieves a task by ID.
  Future<Task?> getTaskById(String id) {
    return (select(tasks)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Watches a single task by ID.
  Stream<Task?> watchTaskById(String id) {
    return (select(tasks)..where((t) => t.id.equals(id)))
        .watchSingleOrNull();
  }

  /// Retrieves tasks for a specific farm.
  Future<List<Task>> getTasksByFarm(String farmId) {
    return (select(tasks)
          ..where((t) => t.farmId.equals(farmId))
          ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
        .get();
  }

  /// Watches tasks for a specific farm.
  Stream<List<Task>> watchTasksByFarm(String farmId) {
    return (select(tasks)
          ..where((t) => t.farmId.equals(farmId))
          ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
        .watch();
  }

  /// Retrieves tasks filtered by status.
  Future<List<Task>> getTasksByStatus(String status) {
    return (select(tasks)
          ..where((t) => t.status.equals(status))
          ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
        .get();
  }

  /// Retrieves tasks assigned to a specific user.
  Future<List<Task>> getTasksByAssignee(String assignee) {
    return (select(tasks)
          ..where((t) => t.assignee.equals(assignee))
          ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
        .get();
  }

  /// Retrieves overdue tasks (due date in the past, not completed).
  Future<List<Task>> getOverdueTasks() {
    return (select(tasks)
          ..where((t) =>
              t.dueDate.isSmallerThanValue(DateTime.now()) &
              t.status.equals('COMPLETED').not())
          ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
        .get();
  }

  /// Inserts or replaces a task record.
  Future<void> upsertTask(TasksCompanion task) {
    return into(tasks).insertOnConflictUpdate(task);
  }

  /// Inserts or replaces multiple task records.
  Future<void> upsertTasks(List<TasksCompanion> taskList) {
    return batch((batch) {
      for (final task in taskList) {
        batch.insert(tasks, task, mode: InsertMode.insertOrReplace);
      }
    });
  }

  /// Updates the status of a task.
  Future<void> updateTaskStatus(String id, String status) {
    return (update(tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        status: Value(status),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Deletes a task by ID.
  Future<int> deleteTaskById(String id) {
    return (delete(tasks)..where((t) => t.id.equals(id))).go();
  }

  /// Retrieves unsynced tasks.
  Future<List<Task>> getUnsyncedTasks(DateTime since) {
    return (select(tasks)
          ..where((t) =>
              t.lastSyncedAt.isNull() | t.lastSyncedAt.isSmallerThanValue(since)))
        .get();
  }

  /// Marks a task as synced.
  Future<void> markSynced(String id) {
    return (update(tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(lastSyncedAt: Value(DateTime.now())),
    );
  }
}
