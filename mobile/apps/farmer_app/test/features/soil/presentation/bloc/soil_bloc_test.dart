import 'package:bloc_test/bloc_test.dart';
import 'package:farmer_app/features/soil/domain/entities/soil_analysis_entity.dart';
import 'package:farmer_app/features/soil/domain/usecases/get_soil_analysis_usecase.dart';
import 'package:farmer_app/features/soil/domain/usecases/get_soil_history_usecase.dart';
import 'package:farmer_app/features/soil/presentation/bloc/soil_bloc.dart';
import 'package:farmer_app/features/soil/presentation/bloc/soil_event.dart';
import 'package:farmer_app/features/soil/presentation/bloc/soil_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetSoilAnalysisUseCase extends Mock
    implements GetSoilAnalysisUseCase {}

class MockGetSoilHistoryUseCase extends Mock implements GetSoilHistoryUseCase {}

void main() {
  late MockGetSoilAnalysisUseCase mockGetSoilAnalysis;
  late MockGetSoilHistoryUseCase mockGetSoilHistory;

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

  final testHistory = [
    testAnalysis,
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
      fieldName: 'North Field',
    ),
    SoilAnalysis(
      id: 'soil-3',
      fieldId: 'field-1',
      pH: 6.8,
      organicCarbon: 2.3,
      nitrogen: 200.0,
      phosphorus: 40.0,
      potassium: 240.0,
      texture: SoilTexture.sandyLoam,
      analysisDate: DateTime(2024, 1, 10),
      fieldName: 'North Field',
    ),
  ];

  final from = DateTime(2024, 1, 1);
  final to = DateTime(2024, 6, 30);

  setUp(() {
    mockGetSoilAnalysis = MockGetSoilAnalysisUseCase();
    mockGetSoilHistory = MockGetSoilHistoryUseCase();
  });

  SoilBloc buildBloc() => SoilBloc(
        getSoilAnalysis: mockGetSoilAnalysis,
        getSoilHistory: mockGetSoilHistory,
      );

  group('SoilBloc', () {
    blocTest<SoilBloc, SoilState>(
      'emits [SoilLoading, SoilAnalysisLoaded] when LoadSoilAnalysis succeeds',
      build: () {
        when(() => mockGetSoilAnalysis('field-1'))
            .thenAnswer((_) async => testAnalysis);
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const LoadSoilAnalysis(fieldId: 'field-1')),
      expect: () => [
        const SoilLoading(),
        SoilAnalysisLoaded(
          analysis: testAnalysis,
          selectedFieldId: 'field-1',
        ),
      ],
      verify: (_) {
        verify(() => mockGetSoilAnalysis('field-1')).called(1);
      },
    );

    blocTest<SoilBloc, SoilState>(
      'emits [SoilLoading, SoilError] when LoadSoilAnalysis fails',
      build: () {
        when(() => mockGetSoilAnalysis('field-1'))
            .thenThrow(Exception('Soil data unavailable'));
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const LoadSoilAnalysis(fieldId: 'field-1')),
      expect: () => [
        const SoilLoading(),
        isA<SoilError>().having(
          (e) => e.message,
          'message',
          contains('Soil data unavailable'),
        ),
      ],
    );

    blocTest<SoilBloc, SoilState>(
      'emits [SoilLoading, SoilHistoryLoaded] when LoadSoilHistory succeeds',
      build: () {
        when(() => mockGetSoilHistory(
              'field-1',
              from: from,
              to: to,
            )).thenAnswer((_) async => testHistory);
        return buildBloc();
      },
      act: (bloc) => bloc.add(LoadSoilHistory(
        fieldId: 'field-1',
        from: from,
        to: to,
      )),
      expect: () => [
        const SoilLoading(),
        SoilHistoryLoaded(fieldId: 'field-1', history: testHistory),
      ],
      verify: (_) {
        verify(() => mockGetSoilHistory(
              'field-1',
              from: from,
              to: to,
            )).called(1);
      },
    );

    blocTest<SoilBloc, SoilState>(
      'emits [SoilLoading, SoilError] when LoadSoilHistory fails',
      build: () {
        when(() => mockGetSoilHistory(
              'field-1',
              from: from,
              to: to,
            )).thenThrow(Exception('History unavailable'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(LoadSoilHistory(
        fieldId: 'field-1',
        from: from,
        to: to,
      )),
      expect: () => [
        const SoilLoading(),
        isA<SoilError>(),
      ],
    );

    blocTest<SoilBloc, SoilState>(
      'loads soil history without date range',
      build: () {
        when(() => mockGetSoilHistory(
              'field-1',
              from: null,
              to: null,
            )).thenAnswer((_) async => testHistory);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadSoilHistory(fieldId: 'field-1')),
      expect: () => [
        const SoilLoading(),
        SoilHistoryLoaded(fieldId: 'field-1', history: testHistory),
      ],
    );

    blocTest<SoilBloc, SoilState>(
      'emits [SoilLoading, SoilAnalysisLoaded] on SelectField',
      build: () {
        when(() => mockGetSoilAnalysis('field-2'))
            .thenAnswer((_) async => testAnalysis.copyWith(
                  fieldId: 'field-2',
                  fieldName: 'South Field',
                ));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const SelectField(fieldId: 'field-2')),
      expect: () => [
        const SoilLoading(),
        isA<SoilAnalysisLoaded>().having(
          (s) => s.selectedFieldId,
          'selectedFieldId',
          'field-2',
        ),
      ],
    );

    blocTest<SoilBloc, SoilState>(
      'emits [SoilLoading, SoilError] when SelectField fails',
      build: () {
        when(() => mockGetSoilAnalysis('field-999'))
            .thenThrow(Exception('Field not found'));
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const SelectField(fieldId: 'field-999')),
      expect: () => [
        const SoilLoading(),
        isA<SoilError>(),
      ],
    );

    test('initial state is SoilInitial', () {
      final bloc = buildBloc();
      expect(bloc.state, const SoilInitial());
      bloc.close();
    });
  });
}
