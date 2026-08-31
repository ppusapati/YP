import 'package:farmer_app/features/soil/domain/entities/soil_analysis_entity.dart';
import 'package:farmer_app/features/soil/domain/repositories/soil_repository.dart';
import 'package:farmer_app/features/soil/domain/usecases/get_soil_analysis_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSoilRepository extends Mock implements SoilRepository {}

void main() {
  late MockSoilRepository mockRepository;
  late GetSoilAnalysisUseCase useCase;

  final testAnalysis = SoilAnalysis(
    id: 'soil-1',
    fieldId: 'field-1',
    pH: 6.5,
    organicCarbon: 2.1,
    nitrogen: 180.0,
    phosphorus: 35.0,
    potassium: 220.0,
    texture: SoilTexture.loamy,
    analysisDate: DateTime(2024, 6, 10),
    fieldName: 'North Field',
  );

  setUp(() {
    mockRepository = MockSoilRepository();
    useCase = GetSoilAnalysisUseCase(mockRepository);
  });

  group('GetSoilAnalysisUseCase', () {
    test('returns soil analysis from repository', () async {
      when(() => mockRepository.getSoilAnalysis('field-1'))
          .thenAnswer((_) async => testAnalysis);

      final result = await useCase('field-1');

      expect(result, testAnalysis);
      expect(result.pH, 6.5);
      expect(result.texture, SoilTexture.loamy);
      expect(result.fieldName, 'North Field');
      verify(() => mockRepository.getSoilAnalysis('field-1')).called(1);
    });

    test('propagates exception when analysis not found', () async {
      when(() => mockRepository.getSoilAnalysis('field-999'))
          .thenThrow(Exception('Analysis not found'));

      expect(
        () => useCase('field-999'),
        throwsA(isA<Exception>()),
      );
    });

    test('delegates directly to repository', () async {
      when(() => mockRepository.getSoilAnalysis(any()))
          .thenAnswer((_) async => testAnalysis);

      await useCase('field-1');

      verify(() => mockRepository.getSoilAnalysis('field-1')).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
