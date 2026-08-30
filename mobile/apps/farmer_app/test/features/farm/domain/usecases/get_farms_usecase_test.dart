import 'package:farmer_app/features/farm/domain/entities/farm_entity.dart';
import 'package:farmer_app/features/farm/domain/repositories/farm_repository.dart';
import 'package:farmer_app/features/farm/domain/usecases/get_farms_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';

class MockFarmRepository extends Mock implements FarmRepository {}

void main() {
  late MockFarmRepository mockRepository;
  late GetFarmsUseCase useCase;

  final now = DateTime(2024, 1, 15);
  final testFarms = [
    FarmEntity(
      id: 'farm-1',
      name: 'Sunrise Farm',
      ownerId: 'user-1',
      boundaries: const [
        LatLng(-1.286, 36.817),
        LatLng(-1.287, 36.818),
        LatLng(-1.288, 36.817),
      ],
      totalAreaHectares: 50.0,
      fields: const [],
      createdAt: now,
      updatedAt: now,
    ),
    FarmEntity(
      id: 'farm-2',
      name: 'Valley Farm',
      ownerId: 'user-1',
      boundaries: const [
        LatLng(-1.3, 36.82),
        LatLng(-1.31, 36.83),
      ],
      totalAreaHectares: 120.0,
      fields: const [],
      createdAt: now,
      updatedAt: now,
    ),
  ];

  setUp(() {
    mockRepository = MockFarmRepository();
    useCase = GetFarmsUseCase(mockRepository);
  });

  group('GetFarmsUseCase', () {
    test('returns list of farms from repository', () async {
      when(() => mockRepository.getFarms('user-1'))
          .thenAnswer((_) async => testFarms);

      final result = await useCase('user-1');

      expect(result, testFarms);
      expect(result.length, 2);
      expect(result[0].name, 'Sunrise Farm');
      expect(result[1].name, 'Valley Farm');
      verify(() => mockRepository.getFarms('user-1')).called(1);
    });

    test('returns empty list when user has no farms', () async {
      when(() => mockRepository.getFarms('user-new'))
          .thenAnswer((_) async => []);

      final result = await useCase('user-new');

      expect(result, isEmpty);
    });

    test('propagates exception from repository', () async {
      when(() => mockRepository.getFarms('user-1'))
          .thenThrow(Exception('Database error'));

      expect(
        () => useCase('user-1'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
