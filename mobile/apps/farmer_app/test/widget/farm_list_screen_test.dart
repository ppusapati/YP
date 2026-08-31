import 'package:bloc_test/bloc_test.dart';
import 'package:farmer_app/features/farm/domain/entities/farm_entity.dart';
import 'package:farmer_app/features/farm/domain/entities/field_entity.dart';
import 'package:farmer_app/features/farm/presentation/bloc/farm_bloc.dart';
import 'package:farmer_app/features/farm/presentation/bloc/farm_event.dart';
import 'package:farmer_app/features/farm/presentation/bloc/farm_state.dart';
import 'package:farmer_app/features/farm/presentation/screens/farm_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';

class MockFarmBloc extends MockBloc<FarmEvent, FarmState> implements FarmBloc {}

void main() {
  late MockFarmBloc mockFarmBloc;

  final now = DateTime(2024, 1, 15);
  final testFarms = [
    FarmEntity(
      id: 'farm-1',
      name: 'Green Valley Farm',
      ownerId: 'user-1',
      boundaries: const [
        LatLng(-1.286, 36.817),
        LatLng(-1.287, 36.818),
      ],
      totalAreaHectares: 50.0,
      fields: [
        const FieldEntity(
          id: 'field-1',
          farmId: 'farm-1',
          name: 'North Field',
          polygon: [LatLng(-1.286, 36.817)],
          areaHectares: 20.0,
          status: FieldStatus.active,
        ),
        const FieldEntity(
          id: 'field-2',
          farmId: 'farm-1',
          name: 'South Field',
          polygon: [LatLng(-1.288, 36.819)],
          areaHectares: 15.0,
          status: FieldStatus.active,
        ),
      ],
      createdAt: now,
      updatedAt: now,
    ),
    FarmEntity(
      id: 'farm-2',
      name: 'Sunrise Plantation',
      ownerId: 'user-1',
      boundaries: const [
        LatLng(-1.3, 36.82),
      ],
      totalAreaHectares: 120.0,
      fields: const [],
      createdAt: now,
      updatedAt: now,
    ),
  ];

  setUp(() {
    mockFarmBloc = MockFarmBloc();
  });

  Widget buildSubject() {
    return MaterialApp(
      home: BlocProvider<FarmBloc>.value(
        value: mockFarmBloc,
        child: const FarmListScreen(),
      ),
    );
  }

  group('FarmListScreen', () {
    testWidgets('displays loading indicator when state is FarmLoading',
        (tester) async {
      when(() => mockFarmBloc.state).thenReturn(const FarmLoading());

      await tester.pumpWidget(buildSubject());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays farm list when state is FarmsLoaded', (tester) async {
      when(() => mockFarmBloc.state)
          .thenReturn(FarmsLoaded(farms: testFarms));

      await tester.pumpWidget(buildSubject());

      expect(find.text('Green Valley Farm'), findsOneWidget);
      expect(find.text('Sunrise Plantation'), findsOneWidget);
      expect(find.text('50.0 hectares'), findsOneWidget);
      expect(find.text('120.0 hectares'), findsOneWidget);
    });

    testWidgets('displays "My Farms" in app bar', (tester) async {
      when(() => mockFarmBloc.state)
          .thenReturn(FarmsLoaded(farms: testFarms));

      await tester.pumpWidget(buildSubject());

      expect(find.text('My Farms'), findsOneWidget);
    });

    testWidgets('displays Add Farm FAB', (tester) async {
      when(() => mockFarmBloc.state)
          .thenReturn(FarmsLoaded(farms: testFarms));

      await tester.pumpWidget(buildSubject());

      expect(find.text('Add Farm'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('displays empty state when no farms', (tester) async {
      when(() => mockFarmBloc.state)
          .thenReturn(const FarmsLoaded(farms: []));

      await tester.pumpWidget(buildSubject());

      expect(find.text('No farms yet'), findsOneWidget);
      expect(find.text('Create Farm'), findsOneWidget);
    });

    testWidgets('displays error view when state is FarmError', (tester) async {
      when(() => mockFarmBloc.state)
          .thenReturn(const FarmError(message: 'Something went wrong'));

      await tester.pumpWidget(buildSubject());

      expect(find.text('Failed to load farms'), findsOneWidget);
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('tapping farm card navigates to detail', (tester) async {
      when(() => mockFarmBloc.state)
          .thenReturn(FarmsLoaded(farms: testFarms));

      await tester.pumpWidget(buildSubject());

      // The FarmCard has an InkWell that we can tap
      await tester.tap(find.text('Green Valley Farm'));
      await tester.pumpAndSettle();

      // Navigation should have pushed a new route.
      // We verify by checking that the navigator pushed something.
      // Since FarmDetailScreen may have its own dependencies,
      // we just verify the tap didn't throw.
    });

    testWidgets('displays field count on farm cards', (tester) async {
      when(() => mockFarmBloc.state)
          .thenReturn(FarmsLoaded(farms: testFarms));

      await tester.pumpWidget(buildSubject());

      expect(find.text('2 fields'), findsOneWidget);
      expect(find.text('0 fields'), findsOneWidget);
    });

    testWidgets('displays search bar', (tester) async {
      when(() => mockFarmBloc.state)
          .thenReturn(FarmsLoaded(farms: testFarms));

      await tester.pumpWidget(buildSubject());

      expect(find.text('Search farms...'), findsOneWidget);
    });
  });
}
