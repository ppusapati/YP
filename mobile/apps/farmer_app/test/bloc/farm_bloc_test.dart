import 'package:bloc_test/bloc_test.dart';
import 'package:farmer_app/features/farm/domain/entities/farm_entity.dart';
import 'package:farmer_app/features/farm/domain/repositories/farm_repository.dart';
import 'package:farmer_app/features/farm/presentation/bloc/farm_bloc.dart';
import 'package:farmer_app/features/farm/presentation/bloc/farm_event.dart';
import 'package:farmer_app/features/farm/presentation/bloc/farm_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';

class MockFarmRepository extends Mock implements FarmRepository {}

void main() {
  late MockFarmRepository mockRepository;

  final now = DateTime(2024, 1, 15);
  final testFarm = FarmEntity(
    id: 'farm-1',
    name: 'Test Farm',
    ownerId: 'user-1',
    boundaries: const [
      LatLng(-1.286389, 36.817223),
      LatLng(-1.287, 36.818),
      LatLng(-1.288, 36.817),
    ],
    totalAreaHectares: 50.0,
    fields: const [],
    createdAt: now,
    updatedAt: now,
  );

  final testFarm2 = FarmEntity(
    id: 'farm-2',
    name: 'Second Farm',
    ownerId: 'user-1',
    boundaries: const [
      LatLng(-1.3, 36.82),
      LatLng(-1.31, 36.83),
      LatLng(-1.32, 36.82),
    ],
    totalAreaHectares: 120.0,
    fields: const [],
    createdAt: now,
    updatedAt: now,
  );

  setUp(() {
    mockRepository = MockFarmRepository();
  });

  setUpAll(() {
    registerFallbackValue(testFarm);
  });

  group('FarmBloc', () {
    blocTest<FarmBloc, FarmState>(
      'emits [FarmLoading, FarmsLoaded] when LoadFarms succeeds',
      build: () {
        when(() => mockRepository.getFarms('user-1'))
            .thenAnswer((_) async => [testFarm, testFarm2]);
        return FarmBloc(farmRepository: mockRepository);
      },
      act: (bloc) => bloc.add(const LoadFarms(userId: 'user-1')),
      expect: () => [
        const FarmLoading(),
        FarmsLoaded(farms: [testFarm, testFarm2]),
      ],
      verify: (_) {
        verify(() => mockRepository.getFarms('user-1')).called(1);
      },
    );

    blocTest<FarmBloc, FarmState>(
      'emits [FarmLoading, FarmError] when LoadFarms fails',
      build: () {
        when(() => mockRepository.getFarms('user-1'))
            .thenThrow(Exception('Network error'));
        return FarmBloc(farmRepository: mockRepository);
      },
      act: (bloc) => bloc.add(const LoadFarms(userId: 'user-1')),
      expect: () => [
        const FarmLoading(),
        isA<FarmError>().having(
          (e) => e.message,
          'message',
          contains('Network error'),
        ),
      ],
    );

    blocTest<FarmBloc, FarmState>(
      'emits [FarmLoading, FarmCreated] on successful CreateFarm',
      build: () {
        when(() => mockRepository.createFarm(any()))
            .thenAnswer((_) async => testFarm);
        return FarmBloc(farmRepository: mockRepository);
      },
      act: (bloc) => bloc.add(CreateFarm(farm: testFarm)),
      expect: () => [
        const FarmLoading(),
        FarmCreated(farm: testFarm),
      ],
      verify: (_) {
        verify(() => mockRepository.createFarm(any())).called(1);
      },
    );

    blocTest<FarmBloc, FarmState>(
      'emits [FarmLoading, FarmError] when CreateFarm fails',
      build: () {
        when(() => mockRepository.createFarm(any()))
            .thenThrow(Exception('Server error'));
        return FarmBloc(farmRepository: mockRepository);
      },
      act: (bloc) => bloc.add(CreateFarm(farm: testFarm)),
      expect: () => [
        const FarmLoading(),
        isA<FarmError>(),
      ],
    );

    blocTest<FarmBloc, FarmState>(
      'emits [FarmLoading, FarmUpdated] on successful UpdateFarm',
      build: () {
        final updatedFarm = testFarm.copyWith(name: 'Updated Farm');
        when(() => mockRepository.updateFarm(any()))
            .thenAnswer((_) async => updatedFarm);
        return FarmBloc(farmRepository: mockRepository);
      },
      act: (bloc) {
        final updatedFarm = testFarm.copyWith(name: 'Updated Farm');
        bloc.add(UpdateFarm(farm: updatedFarm));
      },
      expect: () => [
        const FarmLoading(),
        isA<FarmUpdated>().having(
          (s) => s.farm.name,
          'farm.name',
          'Updated Farm',
        ),
      ],
      verify: (_) {
        verify(() => mockRepository.updateFarm(any())).called(1);
      },
    );

    blocTest<FarmBloc, FarmState>(
      'emits [FarmLoading, FarmError] when UpdateFarm fails',
      build: () {
        when(() => mockRepository.updateFarm(any()))
            .thenThrow(Exception('Update failed'));
        return FarmBloc(farmRepository: mockRepository);
      },
      act: (bloc) => bloc.add(UpdateFarm(farm: testFarm)),
      expect: () => [
        const FarmLoading(),
        isA<FarmError>(),
      ],
    );

    blocTest<FarmBloc, FarmState>(
      'emits [FarmLoading, FarmDeleted] on successful DeleteFarm',
      build: () {
        when(() => mockRepository.deleteFarm('farm-1'))
            .thenAnswer((_) async {});
        return FarmBloc(farmRepository: mockRepository);
      },
      act: (bloc) => bloc.add(const DeleteFarm(farmId: 'farm-1')),
      expect: () => [
        const FarmLoading(),
        const FarmDeleted(),
      ],
    );

    blocTest<FarmBloc, FarmState>(
      'emits [FarmLoading, FarmLoaded] on LoadFarmById',
      build: () {
        when(() => mockRepository.getFarmById('farm-1'))
            .thenAnswer((_) async => testFarm);
        return FarmBloc(farmRepository: mockRepository);
      },
      act: (bloc) => bloc.add(const LoadFarmById(farmId: 'farm-1')),
      expect: () => [
        const FarmLoading(),
        FarmLoaded(farm: testFarm),
      ],
    );

    test('initial state is FarmInitial', () {
      final bloc = FarmBloc(farmRepository: mockRepository);
      expect(bloc.state, const FarmInitial());
      bloc.close();
    });
  });
}
