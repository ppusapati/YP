import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/diagnosis_bloc.dart';
import '../bloc/diagnosis_event.dart';
import '../bloc/diagnosis_state.dart';

/// Screen displaying diagnosis history.
class DiagnosisScreen extends StatefulWidget {
  const DiagnosisScreen({super.key});

  @override
  State<DiagnosisScreen> createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DiagnosisBloc>().add(const LoadDiagnoses());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Plant Diagnosis')),
      body: BlocBuilder<DiagnosisBloc, DiagnosisState>(
        builder: (context, state) {
          if (state is DiagnosisLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DiagnosisError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline,
                      size: 48, color: theme.colorScheme.error),
                  const SizedBox(height: 16),
                  Text(state.message),
                ],
              ),
            );
          }
          if (state is DiagnosesLoaded) {
            if (state.diagnoses.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_florist,
                        size: 80,
                        color: theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.4)),
                    const SizedBox(height: 24),
                    Text('No diagnoses yet',
                        style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text(
                      'Submit a plant image for\nAI-powered disease detection.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.diagnoses.length,
              itemBuilder: (context, index) {
                final d = state.diagnoses[index];
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                        color: theme.colorScheme.outlineVariant),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.coronavirus,
                        color: d.severity == DiseaseSeverity.critical ||
                                d.severity == DiseaseSeverity.severe
                            ? theme.colorScheme.error
                            : theme.colorScheme.primary),
                    title: Text(d.diseaseName),
                    subtitle: Text(
                        '${d.severity.displayName} - ${d.confidencePercent}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/diagnosis/${d.id}'),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/diagnosis/new'),
        icon: const Icon(Icons.camera_alt),
        label: const Text('New Diagnosis'),
      ),
    );
  }
}

// Re-export for convenience
export '../../domain/entities/diagnosis_entity.dart' show DiseaseSeverity;
