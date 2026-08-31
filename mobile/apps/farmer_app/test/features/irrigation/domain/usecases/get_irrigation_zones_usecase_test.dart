import 'package:farmer_app/features/irrigation/domain/entities/irrigation_zone_entity.dart';
import 'package:farmer_app/features/irrigation/domain/repositories/irrigation_repository.dart';
import 'package:farmer_app/features/irrigation/domain/usecases/get_irrigation_zones_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockIrrigationRepository extends Mock implements IrrigationRepository {}

void main() {
  late MockIrrigationRepository mockRepository;
  late GetIrrigationZonesUseCase useCase;

  const testZones = [
    IrrigationZone(
      id: 'zone-1',
      fieldId: 'field-1',
      name: 'Zone Alpha',
      polygon: [
        LatLngPoint(latitude: -1.286, longitude: 36.817),
        LatLngPoint(latitude: -1.287, longitude: 36.818),
      ],
      currentMoisture: 35.0,
      targetMoisture: 60.0,
      status: IrrigationZoneStatus.active,
    ),
    IrrigationZone(
      id: 'zone-2',
      fieldId: 'field-1',
      name: 'Zone Beta',
      polygon: [
        LatLngPoint(latitude: -1.290, longitude: 36.820),
        LatLngPoint(latitude: -1.291, longitude: 36.821),
      ],
      currentMoisture: 55.0,
      targetMoisture: 60.0,
      status: IrrigationZoneStatus.scheduled,
    ),
  ];

  setUp(() {
    mockRepository = MockIrrigationRepository();
    useCase = GetIrrigationZonesUseCase(mockRepository);
  });

  group('GetIrrigationZonesUseCase', () {
    test('returns list of irrigation zones for a field', () async {
      when(() => mockRepository.getIrrigationZones('field-1'))
          .thenAnswer((_) async => testZones);

      final result = await useCase('field-1');

      expect(result, testZones);
      expect(result.length, 2);
      expect(result[0].name, 'Zone Alpha');
      expect(result[1].name, 'Zone Beta');
      verify(() => mockRepository.getIrrigationZones('field-1')).called(1);
    });

    test('returns empty list when field has no zones', () async {
      when(() => mockRepository.getIrrigationZones('field-new'))
          .thenAnswer((_) async => []);

      final result = await useCase('field-new');

      expect(result, isEmpty);
    });

    test('propagates exception from repository', () async {
      when(() => mockRepository.getIrrigationZones('field-1'))
          .thenThrow(Exception('Service unavailable'));

      expect(
        () => useCase('field-1'),
        throwsA(isA<Exception>()),
      );
    });

    test('zone with low moisture reports needsIrrigation', () async {
      when(() => mockRepository.getIrrigationZones('field-1'))
          .thenAnswer((_) async => testZones);

      final result = await useCase('field-1');

      expect(result[0].needsIrrigation, true);
      expect(result[0].moistureDeficit, 25.0);
      expect(result[1].needsIrrigation, true);
      expect(result[1].moistureDeficit, 5.0);
    });
  });
}
