import 'package:flutter/material.dart';

import '../../domain/entities/field_analytics_entity.dart';

/// Card showing yield/stress/NDVI vs mean with colored percentages.
class SeasonComparisonCard extends StatelessWidget {
  const SeasonComparisonCard({
    super.key,
    required this.comparison,
  });

  final SeasonComparison comparison;

  Color _percentColor(double pct, {bool invertBetter = false}) {
    if (invertBetter) {
      return pct <= 0 ? Colors.green : Colors.red;
    }
    return pct >= 0 ? Colors.green : Colors.red;
  }

  String _formatPct(double pct) {
    final sign = pct > 0 ? '+' : '';
    return '$sign${pct.toStringAsFixed(1)}%';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  comparison.season,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                Chip(
                  label: Text(
                    comparison.crop,
                    style: theme.textTheme.labelSmall,
                  ),
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  side: BorderSide.none,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _ComparisonMetric(
                  label: 'Yield',
                  value: '${comparison.yield.toStringAsFixed(1)} t/ha',
                  pctText: _formatPct(comparison.yieldVsMeanPct),
                  pctColor: _percentColor(comparison.yieldVsMeanPct),
                ),
                _ComparisonMetric(
                  label: 'Stress Days',
                  value: '${comparison.stressDays}',
                  pctText: _formatPct(comparison.stressVsMeanPct),
                  pctColor: _percentColor(comparison.stressVsMeanPct,
                      invertBetter: true),
                ),
                _ComparisonMetric(
                  label: 'NDVI Peak',
                  value: comparison.ndviPeak.toStringAsFixed(2),
                  pctText: _formatPct(comparison.ndviVsMeanPct),
                  pctColor: _percentColor(comparison.ndviVsMeanPct),
                ),
              ],
            ),
            if (comparison.notableEvents.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: comparison.notableEvents
                    .map((e) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(e,
                              style: theme.textTheme.labelSmall),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ComparisonMetric extends StatelessWidget {
  const _ComparisonMetric({
    required this.label,
    required this.value,
    required this.pctText,
    required this.pctColor,
  });

  final String label;
  final String value;
  final String pctText;
  final Color pctColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            pctText,
            style: theme.textTheme.labelSmall?.copyWith(
              color: pctColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
