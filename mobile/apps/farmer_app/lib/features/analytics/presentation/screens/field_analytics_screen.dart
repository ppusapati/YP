import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/field_analytics_entity.dart';
import '../bloc/analytics_bloc.dart';
import '../widgets/season_comparison_card.dart';
import '../widgets/yield_trend_chart.dart';

/// Screen showing detailed analytics for a single field.
class FieldAnalyticsScreen extends StatefulWidget {
  const FieldAnalyticsScreen({
    super.key,
    required this.fieldId,
  });

  final String fieldId;

  @override
  State<FieldAnalyticsScreen> createState() => _FieldAnalyticsScreenState();
}

class _FieldAnalyticsScreenState extends State<FieldAnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<AnalyticsBloc>()
        .add(LoadFieldAnalytics(fieldId: widget.fieldId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Field Analytics')),
      body: BlocBuilder<AnalyticsBloc, AnalyticsState>(
        builder: (context, state) {
          if (state is AnalyticsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AnalyticsError) {
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
                        .read<AnalyticsBloc>()
                        .add(LoadFieldAnalytics(fieldId: widget.fieldId)),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is FieldAnalyticsLoaded) {
            return _buildContent(context, state.fieldAnalytics);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, FieldAnalytics analytics) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary metrics
          Card(
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
                  Text('Summary',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _MetricTile(
                        label: 'Mean Yield',
                        value:
                            '${analytics.meanYield.toStringAsFixed(1)} t/ha',
                      ),
                      _MetricTile(
                        label: 'Peak Yield',
                        value:
                            '${analytics.peakYield.toStringAsFixed(1)} t/ha',
                      ),
                      _MetricTile(
                        label: 'Avg NDVI',
                        value: analytics.avgNdvi.toStringAsFixed(2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _MetricTile(
                        label: 'Stress Days',
                        value: analytics.avgStressDays
                            .toStringAsFixed(0),
                      ),
                      _MetricTile(
                        label: 'Seasons',
                        value: '${analytics.seasonsAnalyzed}',
                      ),
                      _MetricTile(
                        label: 'Trend',
                        value: analytics.yieldTrend.displayName,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Yield history chart
          Text('Yield History',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          if (analytics.yieldTrends.isNotEmpty)
            YieldTrendChart(trends: analytics.yieldTrends)
          else
            _EmptySection(message: 'No yield history available'),
          const SizedBox(height: 24),

          // Season comparison cards
          Text('Season Comparisons',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          if (analytics.seasonComparisons.isNotEmpty)
            ...analytics.seasonComparisons
                .map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: SeasonComparisonCard(comparison: s),
                    ))
          else
            _EmptySection(message: 'No season comparison data'),
          const SizedBox(height: 24),

          // Rotation score
          Text('Rotation Score',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          if (analytics.rotationScore != null)
            _RotationScoreCard(score: analytics.rotationScore!)
          else
            _EmptySection(message: 'No rotation data available'),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
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

class _RotationScoreCard extends StatelessWidget {
  const _RotationScoreCard({required this.score});

  final RotationScore score;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color scoreColor() {
      if (score.effectivenessScore >= 80) return Colors.green;
      if (score.effectivenessScore >= 60) return Colors.orange;
      if (score.effectivenessScore >= 40) return Colors.deepOrange;
      return colorScheme.error;
    }

    return Card(
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
              children: [
                SizedBox(
                  width: 56,
                  height: 56,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: score.effectivenessScore / 100,
                        strokeWidth: 5,
                        backgroundColor:
                            colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            scoreColor()),
                      ),
                      Text(
                        '${score.effectivenessScore.toInt()}',
                        style:
                            theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: scoreColor(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rotation Length: ${score.rotationLength} years',
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        'Soil Health: ${score.soilHealthImpact}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (score.recommendations.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...score.recommendations.map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lightbulb_outline,
                            size: 14,
                            color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(r,
                              style: theme.textTheme.bodySmall),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptySection extends StatelessWidget {
  const _EmptySection({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        message,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
