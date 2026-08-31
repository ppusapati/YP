import 'package:bloc_test/bloc_test.dart';
import 'package:farmer_app/features/tasks/domain/entities/task_entity.dart';
import 'package:farmer_app/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:farmer_app/features/tasks/presentation/bloc/task_event.dart';
import 'package:farmer_app/features/tasks/presentation/bloc/task_state.dart';
import 'package:farmer_app/features/tasks/presentation/screens/task_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTaskBloc extends MockBloc<TaskEvent, TaskState>
    implements TaskBloc {}

void main() {
  late MockTaskBloc mockTaskBloc;

  final testTasks = [
    FarmTask(
      id: 'task-1',
      farmId: 'farm-1',
      fieldId: 'field-1',
      title: 'Apply fertilizer to North Field',
      description: 'Apply NPK 20-10-10 at 200 kg/ha.',
      taskType: TaskType.fertilizer,
      status: TaskStatus.pending,
      priority: TaskPriority.high,
      dueDate: DateTime(2030, 7, 15),
      createdAt: DateTime(2024, 6, 10),
    ),
    FarmTask(
      id: 'task-2',
      farmId: 'farm-1',
      fieldId: 'field-2',
      title: 'Scout for pests in South Field',
      description: 'Check for fall armyworm presence.',
      taskType: TaskType.scouting,
      status: TaskStatus.inProgress,
      priority: TaskPriority.medium,
      dueDate: DateTime(2030, 7, 10),
      createdAt: DateTime(2024, 6, 8),
    ),
    FarmTask(
      id: 'task-3',
      farmId: 'farm-1',
      fieldId: 'field-1',
      title: 'Harvest corn',
      description: 'Harvest completed corn field.',
      taskType: TaskType.harvesting,
      status: TaskStatus.completed,
      priority: TaskPriority.low,
      dueDate: DateTime(2024, 6, 20),
      completedDate: DateTime(2024, 6, 19),
      createdAt: DateTime(2024, 6, 1),
    ),
  ];

  setUp(() {
    mockTaskBloc = MockTaskBloc();
  });

  Widget buildSubject({String? farmId}) {
    return MaterialApp(
      home: BlocProvider<TaskBloc>.value(
        value: mockTaskBloc,
        child: TaskListScreen(farmId: farmId),
      ),
    );
  }

  group('TaskListScreen', () {
    testWidgets('displays task list when state is TasksLoaded', (tester) async {
      when(() => mockTaskBloc.state)
          .thenReturn(TasksLoaded(tasks: testTasks));

      await tester.pumpWidget(buildSubject(farmId: 'farm-1'));

      expect(find.text('Apply fertilizer to North Field'), findsOneWidget);
      expect(find.text('Scout for pests in South Field'), findsOneWidget);
      expect(find.text('Harvest corn'), findsOneWidget);
    });

    testWidgets('displays loading indicator when state is TaskLoading',
        (tester) async {
      when(() => mockTaskBloc.state).thenReturn(const TaskLoading());

      await tester.pumpWidget(buildSubject(farmId: 'farm-1'));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays "Tasks" in app bar', (tester) async {
      when(() => mockTaskBloc.state)
          .thenReturn(TasksLoaded(tasks: testTasks));

      await tester.pumpWidget(buildSubject(farmId: 'farm-1'));

      expect(find.text('Tasks'), findsOneWidget);
    });

    testWidgets('displays New Task FAB', (tester) async {
      when(() => mockTaskBloc.state)
          .thenReturn(TasksLoaded(tasks: testTasks));

      await tester.pumpWidget(buildSubject(farmId: 'farm-1'));

      expect(find.text('New Task'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('displays pending and in-progress counts in summary bar',
        (tester) async {
      when(() => mockTaskBloc.state)
          .thenReturn(TasksLoaded(tasks: testTasks));

      await tester.pumpWidget(buildSubject(farmId: 'farm-1'));

      // Summary bar shows counts: "1 Pending", "1 In Progress", "0 Overdue"
      expect(find.textContaining('Pending'), findsOneWidget);
      expect(find.textContaining('In Progress'), findsOneWidget);
    });

    testWidgets('displays filter and refresh buttons in app bar',
        (tester) async {
      when(() => mockTaskBloc.state)
          .thenReturn(TasksLoaded(tasks: testTasks));

      await tester.pumpWidget(buildSubject(farmId: 'farm-1'));

      expect(find.byIcon(Icons.filter_list), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('displays task count', (tester) async {
      when(() => mockTaskBloc.state)
          .thenReturn(TasksLoaded(tasks: testTasks));

      await tester.pumpWidget(buildSubject(farmId: 'farm-1'));

      expect(find.text('3 tasks'), findsOneWidget);
    });

    testWidgets('displays empty state when no tasks match initial state',
        (tester) async {
      when(() => mockTaskBloc.state).thenReturn(const TaskInitial());

      await tester.pumpWidget(buildSubject(farmId: 'farm-1'));

      expect(find.text('No tasks yet'), findsOneWidget);
    });

    testWidgets('displays "No tasks match your filters" when filtered tasks empty',
        (tester) async {
      when(() => mockTaskBloc.state).thenReturn(TasksLoaded(
        tasks: testTasks,
        filteredTasks: const [],
        activeStatusFilter: TaskStatus.cancelled,
      ));

      await tester.pumpWidget(buildSubject(farmId: 'farm-1'));

      expect(find.text('No tasks match your filters'), findsOneWidget);
      expect(find.text('Clear filters'), findsOneWidget);
    });

    testWidgets('displays filtered tasks when filter is active',
        (tester) async {
      when(() => mockTaskBloc.state).thenReturn(TasksLoaded(
        tasks: testTasks,
        filteredTasks: [testTasks[0]],
        activeStatusFilter: TaskStatus.pending,
      ));

      await tester.pumpWidget(buildSubject(farmId: 'farm-1'));

      expect(find.text('Apply fertilizer to North Field'), findsOneWidget);
      // Only one task visible
      expect(find.text('1 task'), findsOneWidget);
    });
  });
}
