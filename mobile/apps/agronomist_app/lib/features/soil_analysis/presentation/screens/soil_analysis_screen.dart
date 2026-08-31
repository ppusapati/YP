import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/soil_analysis_bloc.dart';
import '../bloc/soil_analysis_event.dart';
import '../bloc/soil_analysis_state.dart';
import '../widgets/soil_health_card.dart';

/// Screen displaying soil analysis results for a field.
class SoilAnalysisScreen extends StatefulWidget {
  const SoilAnalysisScreen({super.key, required this.fieldId});

  final String fieldId;

  @override
  State<SoilAnalysisScreen> createState() => _SoilAnalysisScreenState();
}

class _SoilAnalysisScreenState extends State<SoilAnalysisScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<SoilAnalysisBloc>()
        .add(LoadSoilAnalyses(fieldId: widget.fieldId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Soil Analysis')),
      body: BlocBuilder<SoilAnalysisBloc, SoilAnalysisState>(
        builder: (context, state) {
          if (state is SoilAnalysisLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SoilAnalysisError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline,
                      size: 48, color: theme.colorScheme.error),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => context
                        .read<SoilAnalysisBloc>()
                        .add(LoadSoilAnalyses(fieldId: widget.fieldId)),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is SoilAnalysesLoaded) {
            if (state.analyses.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.science,
                        size: 80,
                        color: theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.4)),
                    const SizedBox(height: 24),
                    Text('No soil data',
                        style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text(
                      'Record a soil sample to see\nanalysis results here.',
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
              itemCount: state.analyses.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SoilHealthCard(analysis: state.analyses[index]),
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
