import 'package:bloc_test/bloc_test.dart';
import 'package:farmer_app/features/ai_diagnosis/domain/entities/diagnosis_entity.dart';
import 'package:farmer_app/features/ai_diagnosis/domain/repositories/diagnosis_repository.dart';
import 'package:farmer_app/features/ai_diagnosis/presentation/bloc/diagnosis_bloc.dart';
import 'package:farmer_app/features/ai_diagnosis/presentation/bloc/diagnosis_event.dart';
import 'package:farmer_app/features/ai_diagnosis/presentation/bloc/diagnosis_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDiagnosisRepository extends Mock implements DiagnosisRepository {}

void main() {
  late MockDiagnosisRepository mockRepository;

  final testDiagnosis = Diagnosis(
    id: 'diag-1',
    fieldId: 'field-1',
    imagePath: '/images/leaf_sample.jpg',
    diseaseName: 'Late Blight',
    confidence: 0.92,
    severity: DiagnosisSeverity.moderate,
    description: 'Phytophthora infestans detected on leaf sample.',
    recommendations: [
      'Apply copper-based fungicide',
      'Improve air circulation',
      'Remove infected leaves',
    ],
    createdAt: DateTime(2024, 6, 10),
  );

  final testHistory = [
    testDiagnosis,
    Diagnosis(
      id: 'diag-2',
      fieldId: 'field-1',
      imagePath: '/images/leaf_sample_2.jpg',
      diseaseName: 'Healthy',
      confidence: 0.98,
      severity: DiagnosisSeverity.healthy,
      description: 'No disease detected.',
      recommendations: const [],
      createdAt: DateTime(2024, 6, 8),
    ),
  ];

  setUp(() {
    mockRepository = MockDiagnosisRepository();
  });

  group('DiagnosisBloc', () {
    blocTest<DiagnosisBloc, DiagnosisState>(
      'emits [Diagnosing, DiagnosisComplete] on successful SubmitDiagnosis',
      build: () {
        when(() => mockRepository.submitDiagnosis(
              fieldId: 'field-1',
              imagePath: '/images/leaf_sample.jpg',
            )).thenAnswer((_) async => testDiagnosis);
        return DiagnosisBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(const SubmitDiagnosis(
        fieldId: 'field-1',
        imagePath: '/images/leaf_sample.jpg',
      )),
      expect: () => [
        const Diagnosing(),
        DiagnosisComplete(diagnosis: testDiagnosis),
      ],
      verify: (_) {
        verify(() => mockRepository.submitDiagnosis(
              fieldId: 'field-1',
              imagePath: '/images/leaf_sample.jpg',
            )).called(1);
      },
    );

    blocTest<DiagnosisBloc, DiagnosisState>(
      'emits [Diagnosing, DiagnosisError] when SubmitDiagnosis fails',
      build: () {
        when(() => mockRepository.submitDiagnosis(
              fieldId: any(named: 'fieldId'),
              imagePath: any(named: 'imagePath'),
            )).thenThrow(Exception('Analysis service unavailable'));
        return DiagnosisBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(const SubmitDiagnosis(
        fieldId: 'field-1',
        imagePath: '/images/leaf.jpg',
      )),
      expect: () => [
        const Diagnosing(),
        isA<DiagnosisError>().having(
          (e) => e.message,
          'message',
          contains('Analysis service unavailable'),
        ),
      ],
    );

    blocTest<DiagnosisBloc, DiagnosisState>(
      'emits ImageCaptured on CaptureImage',
      build: () => DiagnosisBloc(repository: mockRepository),
      act: (bloc) => bloc.add(const CaptureImage()),
      expect: () => [
        isA<ImageCaptured>(),
      ],
    );

    blocTest<DiagnosisBloc, DiagnosisState>(
      'emits [DiagnosisLoading, DiagnosisHistoryLoaded] on LoadDiagnosisHistory',
      build: () {
        when(() => mockRepository.getDiagnosisHistory(fieldId: 'field-1'))
            .thenAnswer((_) async => testHistory);
        return DiagnosisBloc(repository: mockRepository);
      },
      act: (bloc) =>
          bloc.add(const LoadDiagnosisHistory(fieldId: 'field-1')),
      expect: () => [
        const DiagnosisLoading(),
        DiagnosisHistoryLoaded(diagnoses: testHistory),
      ],
    );

    blocTest<DiagnosisBloc, DiagnosisState>(
      'emits [DiagnosisLoading, DiagnosisError] when LoadDiagnosisHistory fails',
      build: () {
        when(() => mockRepository.getDiagnosisHistory(fieldId: any(named: 'fieldId')))
            .thenThrow(Exception('History unavailable'));
        return DiagnosisBloc(repository: mockRepository);
      },
      act: (bloc) =>
          bloc.add(const LoadDiagnosisHistory(fieldId: 'field-1')),
      expect: () => [
        const DiagnosisLoading(),
        isA<DiagnosisError>(),
      ],
    );

    blocTest<DiagnosisBloc, DiagnosisState>(
      'loads all history when no fieldId provided',
      build: () {
        when(() => mockRepository.getDiagnosisHistory(fieldId: null))
            .thenAnswer((_) async => testHistory);
        return DiagnosisBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(const LoadDiagnosisHistory()),
      expect: () => [
        const DiagnosisLoading(),
        DiagnosisHistoryLoaded(diagnoses: testHistory),
      ],
    );

    test('initial state is DiagnosisInitial', () {
      final bloc = DiagnosisBloc(repository: mockRepository);
      expect(bloc.state, const DiagnosisInitial());
      bloc.close();
    });
  });
}
