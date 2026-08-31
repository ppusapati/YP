import 'package:farmer_app/features/tasks/data/datasources/task_local_datasource.dart';
import 'package:farmer_app/features/tasks/data/datasources/task_remote_datasource.dart';
import 'package:farmer_app/features/tasks/data/models/task_model.dart';
import 'package:farmer_app/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:farmer_app/features/tasks/domain/entities/task_entity.dart';
import 'package:flutter_network/flutter_network.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTaskRemoteDataSource extends Mock implements TaskRemoteDataSource {}

class MockTaskLocalDataSource extends Mock implements TaskLocalDataSource {}

void main() {
  late MockTaskRemoteDataSource mockRemote;
  late MockTaskLocalDataSource mockLocal;
  late TaskRepositoryImpl repository;

  final testTaskModel1 = TaskModel(
    id: 'task-1',
    farmId: 'farm-1',
    fieldId: 'field-1',
    title: 'Apply fertilizer',
    description: 'Apply NPK at 200 kg/ha.',
    taskType: TaskType.fertilizer,
    status: TaskStatus.pending,
    priority: TaskPriority.high,
    dueDate: DateTime(2024, 7, 15),
    createdAt: DateTime(2024, 6, 10),
  );

  final testTaskModel2 = TaskModel(
    id: 'task-2',
    farmId: 'farm-1',
    fieldId: 'field-2',
    title: 'Scout for pests',
    description: 'Check for fall armyworm.',
    taskType: TaskType.scouting,
    status: TaskStatus.inProgress,
    priority: TaskPriority.medium,
    dueDate: DateTime(2024, 7, 10),
    createdAt: DateTime(2024, 6, 8),
  );

  final completedTaskModel = TaskModel(
    id: 'task-1',
    farmId: 'farm-1',
    fieldId: 'field-1',
    title: 'Apply fertilizer',
    description: 'Apply NPK at 200 kg/ha.',
    taskType: TaskType.fertilizer,
    status: TaskStatus.completed,
    priority: TaskPriority.high,
    dueDate: DateTime(2024, 7, 15),
    completedDate: DateTime(2024, 7, 14),
    createdAt: DateTime(2024, 6, 10),
  );

  setUp(() {
    mockRemote = MockTaskRemoteDataSource();
    mockLocal = MockTaskLocalDataSource();
    repository = TaskRepositoryImpl(
      remoteDataSource: mockRemote,
      localDataSource: mockLocal,
    );
  });

  setUpAll(() {
    registerFallbackValue(testTaskModel1);
    registerFallbackValue(<TaskModel>[]);
  });

  group('TaskRepositoryImpl', () {
    group('getTasks', () {
      test('fetches tasks from remote and caches them', () async {
        when(() => mockRemote.fetchTasks(
              farmId: 'farm-1',
              status: null,
              taskType: null,
            )).thenAnswer((_) async => [testTaskModel1, testTaskModel2]);
        when(() => mockLocal.cacheTasks(any()))
            .thenAnswer((_) async {});

        final result = await repository.getTasks(farmId: 'farm-1');

        expect(result.length, 2);
        expect(result[0].id, 'task-1');
        expect(result[1].id, 'task-2');
        verify(() => mockRemote.fetchTasks(
              farmId: 'farm-1',
              status: null,
              taskType: null,
            )).called(1);
        verify(() => mockLocal.cacheTasks(any())).called(1);
      });

      test('returns cached tasks when remote throws ConnectException', () async {
        when(() => mockRemote.fetchTasks(
              farmId: any(named: 'farmId'),
              status: any(named: 'status'),
              taskType: any(named: 'taskType'),
            )).thenThrow(const ConnectException(message: 'Offline'));
        when(() => mockLocal.getCachedTasks())
            .thenAnswer((_) async => [testTaskModel1]);

        final result = await repository.getTasks(farmId: 'farm-1');

        expect(result.length, 1);
        expect(result[0].id, 'task-1');
        verify(() => mockLocal.getCachedTasks()).called(1);
      });

      test('fetches tasks with status filter', () async {
        when(() => mockRemote.fetchTasks(
              farmId: 'farm-1',
              status: TaskStatus.pending,
              taskType: null,
            )).thenAnswer((_) async => [testTaskModel1]);
        when(() => mockLocal.cacheTasks(any()))
            .thenAnswer((_) async {});

        final result = await repository.getTasks(
          farmId: 'farm-1',
          status: TaskStatus.pending,
        );

        expect(result.length, 1);
        expect(result[0].status, TaskStatus.pending);
      });
    });

    group('createTask', () {
      test('creates task online and caches it', () async {
        when(() => mockRemote.createTask(any()))
            .thenAnswer((_) async => testTaskModel1);
        when(() => mockLocal.cacheTask(any()))
            .thenAnswer((_) async {});

        final task = testTaskModel1 as FarmTask;
        final result = await repository.createTask(task);

        expect(result.id, 'task-1');
        expect(result.title, 'Apply fertilizer');
        verify(() => mockRemote.createTask(any())).called(1);
        verify(() => mockLocal.cacheTask(any())).called(1);
      });

      test('throws when remote create fails', () async {
        when(() => mockRemote.createTask(any()))
            .thenThrow(const ConnectException(message: 'Server error'));

        expect(
          () => repository.createTask(testTaskModel1),
          throwsA(isA<ConnectException>()),
        );
      });
    });

    group('completeTask', () {
      test('completes task via remote and caches result', () async {
        when(() => mockRemote.completeTask('task-1'))
            .thenAnswer((_) async => completedTaskModel);
        when(() => mockLocal.cacheTask(any()))
            .thenAnswer((_) async {});

        final result = await repository.completeTask('task-1');

        expect(result.status, TaskStatus.completed);
        expect(result.completedDate, isNotNull);
        verify(() => mockRemote.completeTask('task-1')).called(1);
        verify(() => mockLocal.cacheTask(any())).called(1);
      });
    });

    group('updateTask', () {
      test('updates task via remote and caches result', () async {
        final updatedModel = TaskModel(
          id: 'task-1',
          farmId: 'farm-1',
          fieldId: 'field-1',
          title: 'Updated title',
          description: 'Updated description.',
          taskType: TaskType.fertilizer,
          status: TaskStatus.pending,
          priority: TaskPriority.urgent,
          dueDate: DateTime(2024, 7, 15),
          createdAt: DateTime(2024, 6, 10),
        );
        when(() => mockRemote.updateTask(any()))
            .thenAnswer((_) async => updatedModel);
        when(() => mockLocal.cacheTask(any()))
            .thenAnswer((_) async {});

        final result = await repository.updateTask(updatedModel);

        expect(result.title, 'Updated title');
        expect(result.priority, TaskPriority.urgent);
        verify(() => mockRemote.updateTask(any())).called(1);
      });
    });

    group('deleteTask', () {
      test('deletes from both remote and local', () async {
        when(() => mockRemote.deleteTask('task-1'))
            .thenAnswer((_) async {});
        when(() => mockLocal.removeTask('task-1'))
            .thenAnswer((_) async {});

        await repository.deleteTask('task-1');

        verify(() => mockRemote.deleteTask('task-1')).called(1);
        verify(() => mockLocal.removeTask('task-1')).called(1);
      });
    });
  });
}
