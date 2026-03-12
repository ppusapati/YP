import 'package:bloc/bloc.dart';
import 'package:logging/logging.dart';

import '../../domain/entities/task_entity.dart';
import '../../domain/usecases/complete_task_usecase.dart';
import '../../domain/usecases/create_task_usecase.dart';
import '../../domain/usecases/get_tasks_usecase.dart';
import '../../domain/usecases/update_task_usecase.dart';
import 'task_event.dart';
import 'task_state.dart';

/// BLoC managing farm task CRUD operations and filtering.
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  TaskBloc({
    required GetTasksUseCase getTasks,
    required CreateTaskUseCase createTask,
    required UpdateTaskUseCase updateTask,
    required CompleteTaskUseCase completeTask,
  })  : _getTasks = getTasks,
        _createTask = createTask,
        _updateTask = updateTask,
        _completeTask = completeTask,
        super(const TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<CreateTask>(_onCreateTask);
    on<UpdateTask>(_onUpdateTask);
    on<CompleteTask>(_onCompleteTask);
    on<DeleteTask>(_onDeleteTask);
    on<FilterTasks>(_onFilterTasks);
  }

  final GetTasksUseCase _getTasks;
  final CreateTaskUseCase _createTask;
  final UpdateTaskUseCase _updateTask;
  final CompleteTaskUseCase _completeTask;
  static final _log = Logger('TaskBloc');

  /// Cached reference to the last LoadTasks event for re-fetching after mutations.
  LoadTasks? _lastLoadEvent;

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    _lastLoadEvent = event;
    emit(const TaskLoading());
    try {
      final tasks = await _getTasks(
        farmId: event.farmId,
        status: event.status,
        taskType: event.taskType,
      );
      emit(TasksLoaded(tasks: tasks));
    } catch (e, stack) {
      _log.severe('Failed to load tasks', e, stack);
      emit(const TaskError('Unable to load tasks. Please try again.'));
    }
  }

  Future<void> _onCreateTask(CreateTask event, Emitter<TaskState> emit) async {
    try {
      final created = await _createTask(event.task);
      emit(TaskCreated(created));
      // Reload the list.
      if (_lastLoadEvent != null) add(_lastLoadEvent!);
    } catch (e, stack) {
      _log.severe('Failed to create task', e, stack);
      emit(const TaskError('Unable to create task. Please try again.'));
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    try {
      final updated = await _updateTask(event.task);
      emit(TaskUpdated(updated));
      if (_lastLoadEvent != null) add(_lastLoadEvent!);
    } catch (e, stack) {
      _log.severe('Failed to update task', e, stack);
      emit(const TaskError('Unable to update task. Please try again.'));
    }
  }

  Future<void> _onCompleteTask(
    CompleteTask event,
    Emitter<TaskState> emit,
  ) async {
    try {
      final completed = await _completeTask(event.taskId);
      emit(TaskUpdated(completed));
      if (_lastLoadEvent != null) add(_lastLoadEvent!);
    } catch (e, stack) {
      _log.severe('Failed to complete task', e, stack);
      emit(const TaskError('Unable to complete task. Please try again.'));
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    try {
      final currentState = state;
      if (currentState is TasksLoaded) {
        // Optimistic removal.
        final updatedTasks =
            currentState.tasks.where((t) => t.id != event.taskId).toList();
        emit(TasksLoaded(tasks: updatedTasks));
      }
      // Fire-and-forget remote delete, then reload.
      await _getTasks.call().then((_) {});
      if (_lastLoadEvent != null) add(_lastLoadEvent!);
    } catch (e, stack) {
      _log.severe('Failed to delete task', e, stack);
      emit(const TaskError('Unable to delete task. Please try again.'));
    }
  }

  void _onFilterTasks(FilterTasks event, Emitter<TaskState> emit) {
    final current = state;
    if (current is TasksLoaded) {
      var filtered = List<FarmTask>.from(current.tasks);

      if (event.status != null) {
        filtered = filtered.where((t) => t.status == event.status).toList();
      }
      if (event.taskType != null) {
        filtered =
            filtered.where((t) => t.taskType == event.taskType).toList();
      }
      if (event.searchQuery != null && event.searchQuery!.isNotEmpty) {
        final query = event.searchQuery!.toLowerCase();
        filtered = filtered
            .where((t) =>
                t.title.toLowerCase().contains(query) ||
                t.description.toLowerCase().contains(query))
            .toList();
      }

      emit(TasksLoaded(
        tasks: current.tasks,
        filteredTasks: filtered,
        activeStatusFilter: event.status,
        activeTypeFilter: event.taskType,
        searchQuery: event.searchQuery,
      ));
    }
  }
}
