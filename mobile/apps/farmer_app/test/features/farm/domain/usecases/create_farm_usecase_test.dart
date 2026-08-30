import 'package:farmer_app/features/farm/domain/entities/farm_entity.dart';
import 'package:farmer_app/features/farm/domain/repositories/farm_repository.dart';
import 'package:farmer_app/features/farm/domain/usecases/create_farm_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';

class MockFarmRepository extends Mock implements FarmRepository {}

void main() {
  late MockFarmRepository mockRepository;
  late CreateFarmUseCase useCase;

  final now = DateTime(2024, 6, 15);
  final newFarm = FarmEntity(
    id: '',
    name: 'New Farm',
    ownerId: 'user-1',
    boundaries: const [
      LatLng(-1.286, 36.817),
      LatLng(-1.287, 36.818),
      LatLng(-1.288, 36.817),
      LatLng(-1.286, 36.817),
    ],
    totalAreaHectares: 75.0,
    fields: const [],
    createdAt: now,
    updatedAt: now,
  );

  final createdFarm = FarmEntity(
    id: 'farm-new-1',
    name: 'New Farm',
    ownerId: 'user-1',
    boundaries: const [
      LatLng(-1.286, 36.817),
      LatLng(-1.287, 36.818),
      LatLng(-1.288, 36.817),
      LatLng(-1.286, 36.817),
    ],
    totalAreaHectares: 75.0,
    fields: const [],
    createdAt: now,
    updatedAt: now,
  );

  setUp(() {
    mockRepository = MockFarmRepository();
    useCase = CreateFarmUseCase(mockRepository);
  });

  setUpAll(() {
    registerFallbackValue(newFarm);
  });

  group('CreateFarmUseCase', () {
    test('creates and returns farm entity', () async {
      when(() => mockRepository.createFarm(any()))
          .thenAnswer((_) async => createdFarm);

      final result = await useCase(newFarm);

      expect(result.id, 'farm-new-1');
      expect(result.name, 'New Farm');
      expect(result.totalAreaHectares, 75.0);
      verify(() => mockRepository.createFarm(any())).called(1);
    });

    test('propagates exception when creation fails', () async {
      when(() => mockRepository.createFarm(any()))
          .thenThrow(Exception('Server unreachable'));

      expect(
        () => useCase(newFarm),
        throwsA(isA<Exception>()),
      );
    });

    test('passes farm entity to repository unchanged', () async {
      late FarmEntity capturedFarm;
      when(() => mockRepository.createFarm(any())).thenAnswer((invocation) {
        capturedFarm = invocation.positionalArguments[0] as FarmEntity;
        return Future.value(createdFarm);
      });

      await useCase(newFarm);

      expect(capturedFarm.name, 'New Farm');
      expect(capturedFarm.ownerId, 'user-1');
      expect(capturedFarm.boundaries.length, 4);
    });
  });
}
