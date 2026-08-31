import 'package:bloc_test/bloc_test.dart';
import 'package:farmer_app/features/tasks/domain/entities/task_entity.dart';
import 'package:farmer_app/features/tasks/domain/usecases/complete_task_usecase.dart';
import 'package:farmer_app/features/tasks/domain/usecases/create_task_usecase.dart';
import 'package:farmer_app/features/tasks/domain/usecases/get_tasks_usecase.dart';
import 'package:farmer_app/features/tasks/domain/usecases/update_task_usecase.dart';
import 'package:farmer_app/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:farmer_app/features/tasks/presentation/bloc/task_event.dart';
import 'package:farmer_app/features/tasks/presentation/bloc/task_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetTasksUseCase extends Mock implements GetTasksUseCase {}

class MockCreateTaskUseCase extends Mock implements CreateTaskUseCase {}

class MockUpdateTaskUseCase extends Mock implements UpdateTaskUseCase {}

class MockCompleteTaskUseCase extends Mock implements CompleteTaskUseCase {}

void main() {
  late MockGetTasksUseCase mockGetTasks;
  late MockCreateTaskUseCase mockCreateTask;
  late MockUpdateTaskUseCase mockUpdateTask;
  late MockCompleteTaskUseCase mockCompleteTask;

  final testTask1 = FarmTask(
    id: 'task-1',
    farmId: 'farm-1',
    fieldId: 'field-1',
    title: 'Apply fertilizer to North Field',
    description: 'Apply NPK 20-10-10 at 200 kg/ha rate.',
    taskType: TaskType.fertilizer,
    status: TaskStatus.pending,
    priority: TaskPriority.high,
    dueDate: DateTime(2024, 7, 15),
    createdAt: DateTime(2024, 6, 10),
  );

  final testTask2 = FarmTask(
    id: 'task-2',
    farmId: 'farm-1',
    fieldId: 'field-2',
    title: 'Scout for pests in South Field',
    description: 'Check for fall armyworm presence.',
    taskType: TaskType.scouting,
    status: TaskStatus.inProgress,
    priority: TaskPriority.medium,
    dueDate: DateTime(2024, 7, 10),
    createdAt: DateTime(2024, 6, 8),
  );

  final completedTask = testTask1.copyWith(
    status: TaskStatus.completed,
    completedDate: DateTime(2024, 7, 14),
  );

  setUp(() {
    mockGetTasks = MockGetTasksUseCase();
    mockCreateTask = MockCreateTaskUseCase();
    mockUpdateTask = MockUpdateTaskUseCase();
    mockCompleteTask = MockCompleteTaskUseCase();
  });

  setUpAll(() {
    registerFallbackValue(testTask1);
  });

  TaskBloc buildBloc() => TaskBloc(
        getTasks: mockGetTasks,
        createTask: mockCreateTask,
        updateTask: mockUpdateTask,
        completeTask: mockCompleteTask,
      );

  group('TaskBloc', () {
    blocTest<TaskBloc, TaskState>(
      'emits [TaskLoading, TasksLoaded] when LoadTasks succeeds',
      build: () {
        when(() => mockGetTasks(
              farmId: 'farm-1',
              status: null,
              taskType: null,
            )).thenAnswer((_) async => [testTask1, testTask2]);
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const LoadTasks(farmId: 'farm-1')),
      expect: () => [
        const TaskLoading(),
        TasksLoaded(tasks: [testTask1, testTask2]),
      ],
    );

    blocTest<TaskBloc, TaskState>(
      'emits [TaskLoading, TaskError] when LoadTasks fails',
      build: () {
        when(() => mockGetTasks(
              farmId: any(named: 'farmId'),
              status: any(named: 'status'),
              taskType: any(named: 'taskType'),
            )).thenThrow(Exception('Network error'));
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const LoadTasks(farmId: 'farm-1')),
      expect: () => [
        const TaskLoading(),
        isA<TaskError>(),
      ],
    );

    blocTest<TaskBloc, TaskState>(
      'emits TaskCreated then reloads on successful CreateTask',
      build: () {
        when(() => mockCreateTask(any()))
            .thenAnswer((_) async => testTask1);
        // The bloc reloads after create, but _lastLoadEvent is null
        // because no LoadTasks was added beforehand.
        return buildBloc();
      },
      act: (bloc) => bloc.add(CreateTask(testTask1)),
      expect: () => [
        TaskCreated(testTask1),
      ],
      verify: (_) {
        verify(() => mockCreateTask(any())).called(1);
      },
    );

    blocTest<TaskBloc, TaskState>(
      'emits TaskError when CreateTask fails',
      build: () {
        when(() => mockCreateTask(any()))
            .thenThrow(Exception('Create failed'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(CreateTask(testTask1)),
      expect: () => [
        isA<TaskError>().having(
          (e) => e.message,
          'message',
          contains('Unable to create task'),
        ),
      ],
    );

    blocTest<TaskBloc, TaskState>(
      'emits TaskUpdated on successful CompleteTask',
      build: () {
        when(() => mockCompleteTask('task-1'))
            .thenAnswer((_) async => completedTask);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const CompleteTask('task-1')),
      expect: () => [
        TaskUpdated(completedTask),
      ],
      verify: (_) {
        verify(() => mockCompleteTask('task-1')).called(1);
      },
    );

    blocTest<TaskBloc, TaskState>(
      'emits TaskError when CompleteTask fails',
      build: () {
        when(() => mockCompleteTask(any()))
            .thenThrow(Exception('Complete failed'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const CompleteTask('task-1')),
      expect: () => [
        isA<TaskError>(),
      ],
    );

    blocTest<TaskBloc, TaskState>(
      'FilterTasks filters by status on existing TasksLoaded',
      build: () => buildBloc(),
      seed: () => TasksLoaded(tasks: [testTask1, testTask2]),
      act: (bloc) =>
          bloc.add(const FilterTasks(status: TaskStatus.pending)),
      expect: () => [
        isA<TasksLoaded>()
            .having(
              (s) => s.filteredTasks?.length,
              'filteredTasks.length',
              1,
            )
            .having(
              (s) => s.activeStatusFilter,
              'activeStatusFilter',
              TaskStatus.pending,
            ),
      ],
    );

    blocTest<TaskBloc, TaskState>(
      'FilterTasks filters by task type on existing TasksLoaded',
      build: () => buildBloc(),
      seed: () => TasksLoaded(tasks: [testTask1, testTask2]),
      act: (bloc) =>
          bloc.add(const FilterTasks(taskType: TaskType.scouting)),
      expect: () => [
        isA<TasksLoaded>()
            .having(
              (s) => s.filteredTasks?.length,
              'filteredTasks.length',
              1,
            )
            .having(
              (s) => s.filteredTasks?.first.id,
              'filteredTask.id',
              'task-2',
            ),
      ],
    );

    blocTest<TaskBloc, TaskState>(
      'FilterTasks with no filters returns all tasks',
      build: () => buildBloc(),
      seed: () => TasksLoaded(tasks: [testTask1, testTask2]),
      act: (bloc) => bloc.add(const FilterTasks()),
      expect: () => [
        isA<TasksLoaded>().having(
          (s) => s.filteredTasks?.length,
          'filteredTasks.length',
          2,
        ),
      ],
    );

    test('initial state is TaskInitial', () {
      final bloc = buildBloc();
      expect(bloc.state, const TaskInitial());
      bloc.close();
    });
  });
}
