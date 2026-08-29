import 'package:flutter/material.dart';

import '../../domain/entities/satellite_data_entity.dart';

/// A card summarizing analytics for a field.
class AnalyticsSummaryCard extends StatelessWidget {
  const AnalyticsSummaryCard({super.key, required this.summary});

  final FieldAnalyticsSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
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
            Text('Field Analytics',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Row(
              children: [
                _MetricTile(
                  label: 'NDVI',
                  value: summary.averageNdvi.toStringAsFixed(2),
                  colorScheme: colorScheme,
                ),
                const SizedBox(width: 12),
                _MetricTile(
                  label: 'NDWI',
                  value: summary.averageNdwi.toStringAsFixed(2),
                  colorScheme: colorScheme,
                ),
                const SizedBox(width: 12),
                _MetricTile(
                  label: 'Health',
                  value: '${summary.healthScore.toInt()}%',
                  colorScheme: colorScheme,
                ),
                const SizedBox(width: 12),
                _MetricTile(
                  label: 'Tiles',
                  value: '${summary.totalTiles}',
                  colorScheme: colorScheme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.colorScheme,
  });

  final String label;
  final String value;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(value,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(label,
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
