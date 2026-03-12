import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ui_core/flutter_ui_core.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/produce_record_entity.dart';
import '../bloc/traceability_bloc.dart';
import '../bloc/traceability_state.dart';
import 'produce_detail_screen.dart';

/// Displays the timeline of produce batches for a farm.
class FarmHistoryScreen extends StatelessWidget {
  const FarmHistoryScreen({super.key, required this.farmName});

  final String farmName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('$farmName History'),
      ),
      body: BlocBuilder<TraceabilityBloc, TraceabilityState>(
        builder: (context, state) {
          if (state is TraceabilityLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is FarmHistoryLoaded) {
            if (state.records.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.history,
                        size: 64, color: theme.colorScheme.outline),
                    const SizedBox(height: 16),
                    Text(
                      'No history available',
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
              );
            }

            return _buildTimeline(context, state.records, theme);
          }

          if (state is TraceabilityError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(state.message, style: theme.textTheme.bodyMedium),
                ],
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildTimeline(
    BuildContext context,
    List<ProduceRecord> records,
    ThemeData theme,
  ) {
    final dateFormat = DateFormat('MMM d, yyyy');

    // Group by year
    final grouped = <int, List<ProduceRecord>>{};
    for (final record in records) {
      final year = record.harvestDate.year;
      grouped.putIfAbsent(year, () => []);
      grouped[year]!.add(record);
    }

    final years = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: years.length,
      itemBuilder: (context, yearIndex) {
        final year = years[yearIndex];
        final yearRecords = grouped[year]!
          ..sort((a, b) => b.harvestDate.compareTo(a.harvestDate));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Year header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '$year',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            // Records for this year
            ...yearRecords.asMap().entries.map((entry) {
              final index = entry.key;
              final record = entry.value;
              final isLast = index == yearRecords.length - 1 &&
                  yearIndex == years.length - 1;

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline rail
                    SizedBox(
                      width: 30,
                      child: Column(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 2,
                                color: theme.colorScheme.outlineVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Card
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => BlocProvider.value(
                                    value: context.read<TraceabilityBloc>(),
                                    child: ProduceDetailScreen(record: record),
                                  ),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.eco_outlined,
                                          size: 20,
                                          color: theme.colorScheme.primary),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          record.cropVariety,
                                          style: theme.textTheme.titleSmall,
                                        ),
                                      ),
                                      Text(
                                        dateFormat
                                            .format(record.harvestDate),
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      _MiniStat(
                                        icon: Icons.medication_outlined,
                                        label:
                                            '${record.treatments.length} treatments',
                                      ),
                                      const SizedBox(width: 16),
                                      _MiniStat(
                                        icon: Icons.verified_outlined,
                                        label:
                                            '${record.certifications.length} certs',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Batch: ${record.batchId}',
                                    style: theme.textTheme.labelSmall
                                        ?.copyWith(
                                      color: theme
                                          .colorScheme.onSurfaceVariant,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
