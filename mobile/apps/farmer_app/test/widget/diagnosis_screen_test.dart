import 'package:bloc_test/bloc_test.dart';
import 'package:farmer_app/features/ai_diagnosis/domain/entities/diagnosis_entity.dart';
import 'package:farmer_app/features/ai_diagnosis/presentation/bloc/diagnosis_bloc.dart';
import 'package:farmer_app/features/ai_diagnosis/presentation/bloc/diagnosis_event.dart';
import 'package:farmer_app/features/ai_diagnosis/presentation/bloc/diagnosis_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDiagnosisBloc extends MockBloc<DiagnosisEvent, DiagnosisState>
    implements DiagnosisBloc {}

/// Minimal diagnosis screen widget for testing.
/// This mirrors the key UI elements from the actual diagnosis screen.
class DiagnosisScreenTestable extends StatelessWidget {
  const DiagnosisScreenTestable({super.key, required this.fieldId});

  final String fieldId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Diagnosis')),
      body: BlocBuilder<DiagnosisBloc, DiagnosisState>(
        builder: (context, state) {
          if (state is DiagnosisInitial) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Take a photo of your crop to get a diagnosis'),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () {
                      context.read<DiagnosisBloc>().add(const CaptureImage());
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Take Photo'),
                  ),
                ],
              ),
            );
          }
          if (state is Diagnosing) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Analyzing image...'),
                ],
              ),
            );
          }
          if (state is DiagnosisComplete) {
            final d = state.diagnosis;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(d.diseaseName,
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text('Confidence: ${(d.confidence * 100).toStringAsFixed(0)}%'),
                  const SizedBox(height: 8),
                  Text('Severity: ${d.severity.displayName}'),
                  const SizedBox(height: 16),
                  Text(d.description),
                  const SizedBox(height: 16),
                  if (d.recommendations.isNotEmpty) ...[
                    const Text('Recommendations:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    ...d.recommendations.map((r) => Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text('- $r'),
                        )),
                  ],
                ],
              ),
            );
          }
          if (state is DiagnosisHistoryLoaded) {
            return ListView.builder(
              itemCount: state.diagnoses.length,
              itemBuilder: (context, index) {
                final d = state.diagnoses[index];
                return ListTile(
                  title: Text(d.diseaseName),
                  subtitle: Text(d.severity.displayName),
                );
              },
            );
          }
          if (state is DiagnosisError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

void main() {
  late MockDiagnosisBloc mockDiagnosisBloc;

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
    ],
    createdAt: DateTime(2024, 6, 10),
  );

  setUp(() {
    mockDiagnosisBloc = MockDiagnosisBloc();
  });

  Widget buildSubject() {
    return MaterialApp(
      home: BlocProvider<DiagnosisBloc>.value(
        value: mockDiagnosisBloc,
        child: const DiagnosisScreenTestable(fieldId: 'field-1'),
      ),
    );
  }

  group('DiagnosisScreen', () {
    testWidgets('shows camera button in initial state', (tester) async {
      when(() => mockDiagnosisBloc.state)
          .thenReturn(const DiagnosisInitial());

      await tester.pumpWidget(buildSubject());

      expect(find.text('Take Photo'), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
    });

    testWidgets('tapping camera button dispatches CaptureImage event',
        (tester) async {
      when(() => mockDiagnosisBloc.state)
          .thenReturn(const DiagnosisInitial());

      await tester.pumpWidget(buildSubject());

      await tester.tap(find.text('Take Photo'));
      await tester.pump();

      verify(() => mockDiagnosisBloc.add(const CaptureImage())).called(1);
    });

    testWidgets('shows analyzing indicator during diagnosis', (tester) async {
      when(() => mockDiagnosisBloc.state)
          .thenReturn(const Diagnosing());

      await tester.pumpWidget(buildSubject());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Analyzing image...'), findsOneWidget);
    });

    testWidgets('displays diagnosis results when complete', (tester) async {
      when(() => mockDiagnosisBloc.state)
          .thenReturn(DiagnosisComplete(diagnosis: testDiagnosis));

      await tester.pumpWidget(buildSubject());

      expect(find.text('Late Blight'), findsOneWidget);
      expect(find.text('Confidence: 92%'), findsOneWidget);
      expect(find.text('Severity: Moderate'), findsOneWidget);
      expect(find.text('Phytophthora infestans detected on leaf sample.'),
          findsOneWidget);
      expect(find.text('Recommendations:'), findsOneWidget);
      expect(find.text('- Apply copper-based fungicide'), findsOneWidget);
      expect(find.text('- Improve air circulation'), findsOneWidget);
    });

    testWidgets('displays diagnosis history list', (tester) async {
      final history = [
        testDiagnosis,
        Diagnosis(
          id: 'diag-2',
          fieldId: 'field-1',
          imagePath: '/images/leaf2.jpg',
          diseaseName: 'Healthy',
          confidence: 0.98,
          severity: DiagnosisSeverity.healthy,
          description: 'No disease detected.',
          recommendations: const [],
          createdAt: DateTime(2024, 6, 8),
        ),
      ];

      when(() => mockDiagnosisBloc.state)
          .thenReturn(DiagnosisHistoryLoaded(diagnoses: history));

      await tester.pumpWidget(buildSubject());

      expect(find.text('Late Blight'), findsOneWidget);
      expect(find.text('Healthy'), findsWidgets);
    });

    testWidgets('displays error message', (tester) async {
      when(() => mockDiagnosisBloc.state)
          .thenReturn(const DiagnosisError(message: 'Service unavailable'));

      await tester.pumpWidget(buildSubject());

      expect(find.text('Service unavailable'), findsOneWidget);
    });

    testWidgets('displays "AI Diagnosis" in app bar', (tester) async {
      when(() => mockDiagnosisBloc.state)
          .thenReturn(const DiagnosisInitial());

      await tester.pumpWidget(buildSubject());

      expect(find.text('AI Diagnosis'), findsOneWidget);
    });
  });
}
