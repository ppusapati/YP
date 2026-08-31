import 'package:farmer_app/features/soil/data/datasources/soil_local_datasource.dart';
import 'package:farmer_app/features/soil/data/datasources/soil_remote_datasource.dart';
import 'package:farmer_app/features/soil/data/models/soil_analysis_model.dart';
import 'package:farmer_app/features/soil/data/repositories/soil_repository_impl.dart';
import 'package:farmer_app/features/soil/domain/entities/soil_analysis_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSoilRemoteDataSource extends Mock implements SoilRemoteDataSource {}

class MockSoilLocalDataSource extends Mock implements SoilLocalDataSource {}

void main() {
  late MockSoilRemoteDataSource mockRemote;
  late MockSoilLocalDataSource mockLocal;
  late SoilRepositoryImpl repository;

  final testAnalysisModel = SoilAnalysisModel(
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

  final testHistoryModels = [
    testAnalysisModel,
    SoilAnalysisModel(
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
    mockRemote = MockSoilRemoteDataSource();
    mockLocal = MockSoilLocalDataSource();
    repository = SoilRepositoryImpl(
      remoteDataSource: mockRemote,
      localDataSource: mockLocal,
    );
  });

  setUpAll(() {
    registerFallbackValue(testAnalysisModel);
    registerFallbackValue(<SoilAnalysisModel>[]);
  });

  group('SoilRepositoryImpl', () {
    group('getSoilAnalysis', () {
      test('returns analysis from remote and caches it', () async {
        when(() => mockRemote.getSoilAnalysis('field-1'))
            .thenAnswer((_) async => testAnalysisModel);
        when(() => mockLocal.cacheAnalysis(any()))
            .thenAnswer((_) async {});

        final result = await repository.getSoilAnalysis('field-1');

        expect(result.id, 'soil-1');
        expect(result.pH, 6.5);
        expect(result.texture, SoilTexture.loamy);
        verify(() => mockRemote.getSoilAnalysis('field-1')).called(1);
        verify(() => mockLocal.cacheAnalysis(any())).called(1);
      });

      test('falls back to cache when remote fails', () async {
        when(() => mockRemote.getSoilAnalysis('field-1'))
            .thenThrow(Exception('Network error'));
        when(() => mockLocal.getCachedAnalysis('field-1'))
            .thenAnswer((_) async => testAnalysisModel);

        final result = await repository.getSoilAnalysis('field-1');

        expect(result.id, 'soil-1');
        verify(() => mockLocal.getCachedAnalysis('field-1')).called(1);
      });

      test('rethrows when remote fails and no cache available', () async {
        when(() => mockRemote.getSoilAnalysis('field-1'))
            .thenThrow(Exception('Network error'));
        when(() => mockLocal.getCachedAnalysis('field-1'))
            .thenAnswer((_) async => null);

        expect(
          () => repository.getSoilAnalysis('field-1'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getSoilHistory', () {
      test('returns history from remote and caches it', () async {
        when(() => mockRemote.getSoilHistory(
              'field-1',
              from: from,
              to: to,
            )).thenAnswer((_) async => testHistoryModels);
        when(() => mockLocal.cacheHistory('field-1', any()))
            .thenAnswer((_) async {});

        final result =
            await repository.getSoilHistory('field-1', from: from, to: to);

        expect(result.length, 2);
        expect(result[0].id, 'soil-1');
        expect(result[1].id, 'soil-2');
        verify(() => mockLocal.cacheHistory('field-1', any())).called(1);
      });

      test('falls back to cache when remote fails', () async {
        when(() => mockRemote.getSoilHistory(
              'field-1',
              from: null,
              to: null,
            )).thenThrow(Exception('Error'));
        when(() => mockLocal.getCachedHistory('field-1'))
            .thenAnswer((_) async => testHistoryModels);

        final result = await repository.getSoilHistory('field-1');

        expect(result.length, 2);
        verify(() => mockLocal.getCachedHistory('field-1')).called(1);
      });

      test('returns empty list when both remote and cache fail', () async {
        when(() => mockRemote.getSoilHistory(
              'field-1',
              from: null,
              to: null,
            )).thenThrow(Exception('Error'));
        when(() => mockLocal.getCachedHistory('field-1'))
            .thenAnswer((_) async => []);

        final result = await repository.getSoilHistory('field-1');

        expect(result, isEmpty);
      });
    });

    group('getAllFieldAnalyses', () {
      test('returns all analyses from remote', () async {
        when(() => mockRemote.getAllFieldAnalyses())
            .thenAnswer((_) async => testHistoryModels);

        final result = await repository.getAllFieldAnalyses();

        expect(result.length, 2);
        verify(() => mockRemote.getAllFieldAnalyses()).called(1);
      });

      test('propagates exception from remote', () async {
        when(() => mockRemote.getAllFieldAnalyses())
            .thenThrow(Exception('Error'));

        expect(
          () => repository.getAllFieldAnalyses(),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
