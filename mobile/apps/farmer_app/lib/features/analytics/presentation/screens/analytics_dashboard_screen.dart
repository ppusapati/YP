import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/field_analytics_entity.dart';
import '../bloc/analytics_bloc.dart';

/// Screen listing all fields with yield trend indicators.
class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AnalyticsBloc>().add(const LoadAnalyticsList());
  }

  IconData _trendIcon(YieldTrendDirection trend) {
    return switch (trend) {
      YieldTrendDirection.increasing => Icons.trending_up,
      YieldTrendDirection.decreasing => Icons.trending_down,
      YieldTrendDirection.stable => Icons.trending_flat,
    };
  }

  Color _trendColor(YieldTrendDirection trend, ColorScheme colorScheme) {
    return switch (trend) {
      YieldTrendDirection.increasing => Colors.green,
      YieldTrendDirection.decreasing => colorScheme.error,
      YieldTrendDirection.stable => Colors.orange,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Historical Analytics')),
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
                        .add(const LoadAnalyticsList()),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is AnalyticsListLoaded) {
            if (state.fieldAnalytics.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.analytics_outlined,
                        size: 80,
                        color: theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.4)),
                    const SizedBox(height: 24),
                    Text('No analytics data yet',
                        style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text(
                      'Analytics will appear once\nyour fields have historical data.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<AnalyticsBloc>()
                    .add(const LoadAnalyticsList());
              },
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: state.fieldAnalytics.length,
                itemBuilder: (context, index) {
                  final analytics = state.fieldAnalytics[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _FieldAnalyticsCard(
                      analytics: analytics,
                      trendIcon: _trendIcon(analytics.yieldTrend),
                      trendColor: _trendColor(
                          analytics.yieldTrend, theme.colorScheme),
                      onTap: () => context
                          .push('/analytics/${analytics.fieldId}'),
                    ),
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _FieldAnalyticsCard extends StatelessWidget {
  const _FieldAnalyticsCard({
    required this.analytics,
    required this.trendIcon,
    required this.trendColor,
    this.onTap,
  });

  final FieldAnalytics analytics;
  final IconData trendIcon;
  final Color trendColor;
  final VoidCallback? onTap;

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
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(trendIcon, color: trendColor, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      analytics.fieldName.isNotEmpty
                          ? analytics.fieldName
                          : 'Field ${analytics.fieldId}',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mean yield: ${analytics.meanYield.toStringAsFixed(1)} t/ha',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${analytics.seasonsAnalyzed} seasons analyzed',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    analytics.yieldTrend.displayName,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: trendColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'NDVI ${analytics.avgNdvi.toStringAsFixed(2)}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
