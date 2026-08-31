import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/diagnosis_bloc.dart';
import '../bloc/diagnosis_event.dart';
import '../bloc/diagnosis_state.dart';

/// Screen showing the result of a plant diagnosis.
class DiagnosisResultScreen extends StatefulWidget {
  const DiagnosisResultScreen({super.key, required this.diagnosisId});

  final String diagnosisId;

  @override
  State<DiagnosisResultScreen> createState() => _DiagnosisResultScreenState();
}

class _DiagnosisResultScreenState extends State<DiagnosisResultScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<DiagnosisBloc>()
        .add(LoadDiagnosisById(id: widget.diagnosisId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Diagnosis Result')),
      body: BlocBuilder<DiagnosisBloc, DiagnosisState>(
        builder: (context, state) {
          if (state is DiagnosisLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DiagnosisError) {
            return Center(child: Text(state.message));
          }
          if (state is DiagnosisLoaded) {
            final d = state.diagnosis;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.coronavirus,
                                  size: 36, color: colorScheme.error),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(d.diseaseName,
                                    style: theme.textTheme.headlineSmall),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Chip(
                                label: Text(d.severity.displayName),
                                backgroundColor: colorScheme.errorContainer,
                              ),
                              const SizedBox(width: 8),
                              Chip(
                                label: Text(d.confidencePercent),
                                backgroundColor: colorScheme.primaryContainer,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Treatment',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(d.treatment, style: theme.textTheme.bodyMedium),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
