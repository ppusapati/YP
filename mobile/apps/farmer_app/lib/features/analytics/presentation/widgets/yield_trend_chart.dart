import 'package:flutter/material.dart';

import '../../domain/entities/field_analytics_entity.dart';

/// Simple bar chart showing yields by year with a trend line.
class YieldTrendChart extends StatelessWidget {
  const YieldTrendChart({
    super.key,
    required this.trends,
    this.height = 200,
  });

  final List<YieldTrend> trends;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (trends.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final maxYield =
        trends.map((t) => t.yieldValue).reduce((a, b) => a > b ? a : b);
    final barColor = colorScheme.primary;

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
            SizedBox(
              height: height,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: trends.map((trend) {
                  final barHeight = maxYield > 0
                      ? (trend.yieldValue / maxYield) * (height - 24)
                      : 0.0;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            trend.yieldValue.toStringAsFixed(1),
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 9,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: barHeight.clamp(4.0, height - 24),
                            decoration: BoxDecoration(
                              color: barColor,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 4),
            Divider(height: 1, color: colorScheme.outlineVariant),
            const SizedBox(height: 4),
            Row(
              children: trends.map((trend) {
                return Expanded(
                  child: Center(
                    child: Text(
                      trend.season,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 9,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
