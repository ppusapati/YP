import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/yield_analysis_bloc.dart';
import '../bloc/yield_analysis_event.dart';
import '../bloc/yield_analysis_state.dart';

class YieldForecastScreen extends StatefulWidget {
  const YieldForecastScreen({super.key, required this.fieldId});
  final String fieldId;

  @override
  State<YieldForecastScreen> createState() => _YieldForecastScreenState();
}

class _YieldForecastScreenState extends State<YieldForecastScreen> {
  @override
  void initState() {
    super.initState();
    context.read<YieldAnalysisBloc>().add(LoadYieldForecast(fieldId: widget.fieldId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Yield Forecast')),
      body: BlocBuilder<YieldAnalysisBloc, YieldAnalysisState>(
        builder: (context, state) {
          if (state is YieldAnalysisLoading) return const Center(child: CircularProgressIndicator());
          if (state is YieldAnalysisError) return Center(child: Text(state.message));
          if (state is YieldForecastLoaded) {
            if (state.predictions.isEmpty) {
              return Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.trending_up, size: 80,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
                  const SizedBox(height: 24),
                  Text('No yield predictions', style: theme.textTheme.headlineSmall),
                ]),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.predictions.length,
              itemBuilder: (context, index) {
                final p = state.predictions[index];
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.eco, color: theme.colorScheme.primary),
                    title: Text('${p.cropName}: ${p.predictedYield.toStringAsFixed(1)} ${p.unit}'),
                    subtitle: Text('Harvest: ${DateFormat.yMMMd().format(p.harvestDate)} - ${p.confidencePercent} confidence'),
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
