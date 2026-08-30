import 'package:farmer_app/features/soil/domain/entities/soil_analysis_entity.dart';
import 'package:farmer_app/features/soil/domain/repositories/soil_repository.dart';
import 'package:farmer_app/features/soil/domain/usecases/get_soil_history_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSoilRepository extends Mock implements SoilRepository {}

void main() {
  late MockSoilRepository mockRepository;
  late GetSoilHistoryUseCase useCase;

  final testHistory = [
    SoilAnalysis(
      id: 'soil-1',
      fieldId: 'field-1',
      pH: 6.5,
      organicCarbon: 2.1,
      nitrogen: 180.0,
      phosphorus: 35.0,
      potassium: 220.0,
      texture: SoilTexture.loamy,
      analysisDate: DateTime(2024, 6, 10),
    ),
    SoilAnalysis(
      id: 'soil-2',
      fieldId: 'field-1',
      pH: 6.2,
      organicCarbon: 1.8,
      nitrogen: 160.0,
      phosphorus: 30.0,
      potassium: 200.0,
      texture: SoilTexture.loamy,
      analysisDate: DateTime(2024, 3, 15),
    ),
  ];

  final from = DateTime(2024, 1, 1);
  final to = DateTime(2024, 6, 30);

  setUp(() {
    mockRepository = MockSoilRepository();
    useCase = GetSoilHistoryUseCase(mockRepository);
  });

  group('GetSoilHistoryUseCase', () {
    test('returns soil history with date range', () async {
      when(() => mockRepository.getSoilHistory(
            'field-1',
            from: from,
            to: to,
          )).thenAnswer((_) async => testHistory);

      final result = await useCase('field-1', from: from, to: to);

      expect(result, testHistory);
      expect(result.length, 2);
      verify(() => mockRepository.getSoilHistory(
            'field-1',
            from: from,
            to: to,
          )).called(1);
    });

    test('returns soil history without date range', () async {
      when(() => mockRepository.getSoilHistory(
            'field-1',
            from: null,
            to: null,
          )).thenAnswer((_) async => testHistory);

      final result = await useCase('field-1');

      expect(result.length, 2);
    });

    test('returns empty list when no history available', () async {
      when(() => mockRepository.getSoilHistory(
            'field-new',
            from: null,
            to: null,
          )).thenAnswer((_) async => []);

      final result = await useCase('field-new');

      expect(result, isEmpty);
    });

    test('propagates exception from repository', () async {
      when(() => mockRepository.getSoilHistory(
            'field-1',
            from: any(named: 'from'),
            to: any(named: 'to'),
          )).thenThrow(Exception('Database error'));

      expect(
        () => useCase('field-1', from: from, to: to),
        throwsA(isA<Exception>()),
      );
    });
  });
}
