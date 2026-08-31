import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// A single yield data point.
class YieldDataPoint {
  const YieldDataPoint({
    required this.label,
    required this.expected,
    this.actual,
    this.confidenceLow,
    this.confidenceHigh,
  });

  /// X-axis label (e.g., crop name or month).
  final String label;

  /// Predicted / expected yield (tonnes/ha or similar).
  final double expected;

  /// Actual observed yield; null if not yet harvested.
  final double? actual;

  /// Lower bound of the prediction confidence interval.
  final double? confidenceLow;

  /// Upper bound of the prediction confidence interval.
  final double? confidenceHigh;
}

/// A grouped bar chart comparing expected vs actual yield with optional
/// confidence interval shading.
class YieldChart extends StatelessWidget {
  const YieldChart({
    super.key,
    required this.data,
    this.height = 240,
    this.unitLabel = 't/ha',
    this.animate = true,
  });

  final List<YieldDataPoint> data;
  final double height;
  final String unitLabel;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return SizedBox(height: height);

    final colorScheme = Theme.of(context).colorScheme;
    final maxVal = data.fold<double>(0, (prev, d) {
      final vals = [d.expected, d.actual ?? 0, d.confidenceHigh ?? 0];
      return vals.fold(prev, (a, b) => a > b ? a : b);
    });
    final yMax = (maxVal * 1.2).ceilToDouble();

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          maxY: yMax,
          minY: 0,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => colorScheme.surface,
              tooltipBorder: BorderSide(color: colorScheme.outlineVariant),
              tooltipRoundedRadius: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final d = data[groupIndex];
                final isExpected = rodIndex == 0;
                return BarTooltipItem(
                  '${isExpected ? "Expected" : "Actual"}\n',
                  AppTypography.chartTooltip.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  children: [
                    TextSpan(
                      text: '${rod.toY.toStringAsFixed(1)} $unitLabel',
                      style: AppTypography.chartTooltip.copyWith(
                        color: isExpected
                            ? AppColors.primary
                            : AppColors.accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (isExpected &&
                        d.confidenceLow != null &&
                        d.confidenceHigh != null)
                      TextSpan(
                        text:
                            '\nCI: ${d.confidenceLow!.toStringAsFixed(1)} – ${d.confidenceHigh!.toStringAsFixed(1)}',
                        style: AppTypography.chartAxis.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: yMax / 5,
            getDrawingHorizontalLine: (v) => FlLine(
              color: colorScheme.outlineVariant.withValues(alpha: 0.4),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: yMax / 5,
                reservedSize: 40,
                getTitlesWidget: (value, meta) => Text(
                  value.toStringAsFixed(1),
                  style: AppTypography.chartAxis.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= data.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      data[idx].label,
                      style: AppTypography.chartAxis.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          barGroups: List.generate(data.length, (i) {
            final d = data[i];
            return BarChartGroupData(
              x: i,
              barsSpace: 4,
              barRods: [
                // Expected
                BarChartRodData(
                  toY: d.expected,
                  width: 14,
                  color: AppColors.primary,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                  backDrawRodData: d.confidenceHigh != null
                      ? BackgroundBarChartRodData(
                          show: true,
                          toY: d.confidenceHigh!,
                          color: AppColors.primaryContainer.withValues(alpha: 0.5),
                        )
                      : null,
                ),
                // Actual (if available)
                if (d.actual != null)
                  BarChartRodData(
                    toY: d.actual!,
                    width: 14,
                    color: AppColors.accent,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
              ],
            );
          }),
        ),
        duration: animate
            ? const Duration(milliseconds: 400)
            : Duration.zero,
      ),
    );
  }
}
