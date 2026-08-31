import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Descriptor for a single crop growth stage.
class GrowthStage {
  const GrowthStage({
    required this.name,
    required this.startDay,
    required this.endDay,
    this.color,
  });

  final String name;

  /// Day offset from planting (e.g. 0).
  final int startDay;

  /// Day offset from planting (e.g. 30).
  final int endDay;

  /// Optional colour for the stage band; a default palette is used otherwise.
  final Color? color;
}

/// A data point on the growth curve.
class GrowthDataPoint {
  const GrowthDataPoint({required this.day, required this.value});

  /// Day offset from planting.
  final int day;

  /// Growth metric (e.g., height in cm, LAI, biomass).
  final double value;
}

/// A crop growth curve chart with growth-stage background bands and a
/// current-stage indicator.
class CropGrowthChart extends StatelessWidget {
  const CropGrowthChart({
    super.key,
    required this.stages,
    required this.data,
    this.currentDay,
    this.height = 240,
    this.yAxisLabel = 'Growth',
    this.animate = true,
  });

  final List<GrowthStage> stages;
  final List<GrowthDataPoint> data;

  /// Current day after planting; shows a vertical indicator line.
  final int? currentDay;

  final double height;
  final String yAxisLabel;
  final bool animate;

  static const _stageColors = [
    Color(0xFFE8F5E9),
    Color(0xFFC8E6C9),
    Color(0xFFA5D6A7),
    Color(0xFF81C784),
    Color(0xFFFFF9C4),
    Color(0xFFFFE0B2),
  ];

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return SizedBox(height: height);

    final colorScheme = Theme.of(context).colorScheme;
    final sorted = List<GrowthDataPoint>.from(data)
      ..sort((a, b) => a.day.compareTo(b.day));

    final minX = sorted.first.day.toDouble();
    final maxX = sorted.last.day.toDouble();
    final maxY = sorted.fold<double>(0, (m, p) => p.value > m ? p.value : m) * 1.15;

    final spots = sorted
        .map((p) => FlSpot(p.day.toDouble(), p.value))
        .toList();

    // Build vertical range annotations for growth stages.
    final rangeAnnotations = <VerticalRangeAnnotation>[];
    for (var i = 0; i < stages.length; i++) {
      final s = stages[i];
      rangeAnnotations.add(VerticalRangeAnnotation(
        x1: s.startDay.toDouble(),
        x2: s.endDay.toDouble(),
        color: (s.color ?? _stageColors[i % _stageColors.length])
            .withValues(alpha: 0.25),
      ));
    }

    // Current-day indicator line.
    final extraVertical = <VerticalLine>[];
    if (currentDay != null) {
      extraVertical.add(VerticalLine(
        x: currentDay!.toDouble(),
        color: AppColors.accent,
        strokeWidth: 2,
        dashArray: [6, 4],
        label: VerticalLineLabel(
          show: true,
          alignment: Alignment.topRight,
          padding: const EdgeInsets.only(left: 4, bottom: 2),
          style: AppTypography.chartTooltip.copyWith(color: AppColors.accent),
          labelResolver: (_) => 'Today',
        ),
      ));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: height,
          child: LineChart(
            LineChartData(
              minX: minX,
              maxX: maxX,
              minY: 0,
              maxY: maxY,
              clipData: const FlClipData.all(),
              rangeAnnotations: RangeAnnotations(
                verticalRangeAnnotations: rangeAnnotations,
              ),
              extraLinesData: ExtraLinesData(verticalLines: extraVertical),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (v) => FlLine(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  axisNameWidget: Text(
                    yAxisLabel,
                    style: AppTypography.chartAxis.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (v, meta) => Text(
                      v.toStringAsFixed(0),
                      style: AppTypography.chartAxis.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  axisNameWidget: Text(
                    'Days after planting',
                    style: AppTypography.chartAxis.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (v, meta) => Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        v.toInt().toString(),
                        style: AppTypography.chartAxis.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => colorScheme.surface,
                  tooltipBorder: BorderSide(color: colorScheme.outlineVariant),
                  tooltipRoundedRadius: 8,
                  getTooltipItems: (spots) => spots.map((spot) {
                    final stage = stages.cast<GrowthStage?>().firstWhere(
                      (s) =>
                          s != null &&
                          spot.x >= s.startDay &&
                          spot.x <= s.endDay,
                      orElse: () => null,
                    );
                    return LineTooltipItem(
                      'Day ${spot.x.toInt()}\n',
                      AppTypography.chartTooltip.copyWith(
                        color: colorScheme.onSurface,
                      ),
                      children: [
                        TextSpan(
                          text: '${spot.y.toStringAsFixed(1)}',
                          style: AppTypography.chartTooltip.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (stage != null)
                          TextSpan(
                            text: '\n${stage.name}',
                            style: AppTypography.chartAxis.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.3,
                  preventCurveOverShooting: true,
                  color: AppColors.primary,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primary.withValues(alpha: 0.20),
                        AppColors.primary.withValues(alpha: 0.02),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            duration: animate
                ? const Duration(milliseconds: 400)
                : Duration.zero,
          ),
        ),
        // Stage legend
        if (stages.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: List.generate(stages.length, (i) {
              final s = stages[i];
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: (s.color ?? _stageColors[i % _stageColors.length])
                          .withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    s.name,
                    style: AppTypography.labelSmall.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ],
    );
  }
}
