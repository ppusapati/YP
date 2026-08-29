import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../bloc/diagnosis_bloc.dart';
import '../bloc/diagnosis_event.dart';
import '../bloc/diagnosis_state.dart';

/// Screen listing past diagnoses.
class DiagnosisHistoryScreen extends StatefulWidget {
  const DiagnosisHistoryScreen({super.key});

  @override
  State<DiagnosisHistoryScreen> createState() =>
      _DiagnosisHistoryScreenState();
}

class _DiagnosisHistoryScreenState extends State<DiagnosisHistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DiagnosisBloc>().add(const LoadDiagnoses());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Diagnosis History')),
      body: BlocBuilder<DiagnosisBloc, DiagnosisState>(
        builder: (context, state) {
          if (state is DiagnosisLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DiagnosisError) {
            return Center(child: Text(state.message));
          }
          if (state is DiagnosesLoaded) {
            if (state.diagnoses.isEmpty) {
              return const Center(child: Text('No diagnosis history.'));
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
                    title: Text(d.diseaseName),
                    subtitle: Text(DateFormat.yMMMd().format(d.diagnosedAt)),
                    trailing: Text(d.severity.displayName,
                        style: theme.textTheme.labelSmall),
                    onTap: () => context.push('/diagnosis/${d.id}'),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
