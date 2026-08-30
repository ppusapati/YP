import 'package:farmer_app/features/observations/domain/entities/observation_entity.dart';
import 'package:farmer_app/features/observations/domain/repositories/observation_repository.dart';
import 'package:farmer_app/features/observations/domain/usecases/get_observations_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';

class MockObservationRepository extends Mock
    implements ObservationRepository {}

void main() {
  late MockObservationRepository mockRepository;
  late GetObservationsUseCase useCase;

  final testObservations = [
    FieldObservation(
      id: 'obs-1',
      fieldId: 'field-1',
      location: const LatLng(-1.286, 36.817),
      photos: const ['https://photos.example.com/obs1.jpg'],
      notes: 'Pest spotted on leaves.',
      timestamp: DateTime(2024, 6, 15, 10, 30),
      category: ObservationCategory.pest,
    ),
    FieldObservation(
      id: 'obs-2',
      fieldId: 'field-2',
      location: const LatLng(-1.290, 36.820),
      photos: const [],
      notes: 'Healthy growth pattern.',
      timestamp: DateTime(2024, 6, 14, 9, 0),
      category: ObservationCategory.growth,
    ),
  ];

  setUp(() {
    mockRepository = MockObservationRepository();
    useCase = GetObservationsUseCase(mockRepository);
  });

  group('GetObservationsUseCase', () {
    test('returns all observations when no fieldId specified', () async {
      when(() => mockRepository.getObservations(fieldId: null))
          .thenAnswer((_) async => testObservations);

      final result = await useCase();

      expect(result, testObservations);
      expect(result.length, 2);
      verify(() => mockRepository.getObservations(fieldId: null)).called(1);
    });

    test('returns filtered observations for specific field', () async {
      when(() => mockRepository.getObservations(fieldId: 'field-1'))
          .thenAnswer((_) async => [testObservations[0]]);

      final result = await useCase(fieldId: 'field-1');

      expect(result.length, 1);
      expect(result[0].fieldId, 'field-1');
    });

    test('returns empty list when no observations exist', () async {
      when(() => mockRepository.getObservations(fieldId: null))
          .thenAnswer((_) async => []);

      final result = await useCase();

      expect(result, isEmpty);
    });

    test('propagates exception from repository', () async {
      when(() => mockRepository.getObservations(fieldId: any(named: 'fieldId')))
          .thenThrow(Exception('Network error'));

      expect(
        () => useCase(fieldId: 'field-1'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
