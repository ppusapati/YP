import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/satellite_bloc.dart';
import '../bloc/satellite_event.dart';
import '../bloc/satellite_state.dart';
import '../widgets/analytics_summary_card.dart';

/// Screen showing analytics dashboard for a field.
class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({
    super.key,
    required this.farmId,
    required this.fieldId,
  });

  final String farmId;
  final String fieldId;

  @override
  State<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SatelliteBloc>().add(
        LoadFieldSummary(farmId: widget.farmId, fieldId: widget.fieldId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: BlocBuilder<SatelliteBloc, SatelliteState>(
        builder: (context, state) {
          if (state is SatelliteLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SatelliteError) {
            return Center(child: Text(state.message));
          }
          if (state is FieldSummaryLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  AnalyticsSummaryCard(summary: state.summary),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                          color: theme.colorScheme.outlineVariant),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Temporal Trends',
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 12),
                          Text(
                            'NDVI trend analysis and historical data\nwill be displayed here.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
