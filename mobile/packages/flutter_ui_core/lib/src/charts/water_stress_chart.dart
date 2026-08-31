import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Single water-stress data point.
class WaterStressPoint {
  const WaterStressPoint({
    required this.date,
    required this.stressIndex,
    this.soilMoisture,
    this.evapotranspiration,
  });

  final DateTime date;

  /// Crop water stress index (0 = no stress, 1 = severe stress).
  final double stressIndex;

  /// Optional soil moisture percentage.
  final double? soilMoisture;

  /// Optional evapotranspiration (mm/day).
  final double? evapotranspiration;
}

/// A combined chart showing crop water stress index as a coloured area chart,
/// optionally overlaying soil moisture and evapotranspiration lines.
class WaterStressChart extends StatelessWidget {
  const WaterStressChart({
    super.key,
    required this.data,
    this.height = 240,
    this.showSoilMoisture = true,
    this.showEvapotranspiration = false,
    this.stressThreshold = 0.5,
    this.animate = true,
  });

  final List<WaterStressPoint> data;
  final double height;
  final bool showSoilMoisture;
  final bool showEvapotranspiration;

  /// Threshold above which stress is considered critical.
  final double stressThreshold;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return SizedBox(height: height);

    final colorScheme = Theme.of(context).colorScheme;
    final sorted = List<WaterStressPoint>.from(data)
      ..sort((a, b) => a.date.compareTo(b.date));

    final minX = sorted.first.date.millisecondsSinceEpoch.toDouble();
    final maxX = sorted.last.date.millisecondsSinceEpoch.toDouble();

    // ── Stress spots ─────────────────────────────────────────────
    final stressSpots = sorted
        .map((p) => FlSpot(
              p.date.millisecondsSinceEpoch.toDouble(),
              p.stressIndex.clamp(0, 1),
            ))
        .toList();

    // ── Soil moisture spots ──────────────────────────────────────
    final moistureSpots = showSoilMoisture
        ? sorted
            .where((p) => p.soilMoisture != null)
            .map((p) => FlSpot(
                  p.date.millisecondsSinceEpoch.toDouble(),
                  p.soilMoisture! / 100, // normalise to 0-1
                ))
            .toList()
        : <FlSpot>[];

    // ── ET spots ─────────────────────────────────────────────────
    double etMax = 1;
    final etSpots = showEvapotranspiration
        ? sorted.where((p) => p.evapotranspiration != null).map((p) {
            if (p.evapotranspiration! > etMax) etMax = p.evapotranspiration!;
            return FlSpot(
              p.date.millisecondsSinceEpoch.toDouble(),
              p.evapotranspiration!,
            );
          }).toList()
        : <FlSpot>[];

    // Use dual axis: left 0-1 (stress / moisture), right for ET if shown.
    // For simplicity we normalise ET to 0-1 range.
    final normalizedEtSpots = etSpots.isNotEmpty
        ? etSpots
            .map((s) => FlSpot(s.x, s.y / (etMax * 1.2)))
            .toList()
        : <FlSpot>[];

    final lines = <LineChartBarData>[
      // Stress area
      LineChartBarData(
        spots: stressSpots,
        isCurved: true,
        curveSmoothness: 0.25,
        preventCurveOverShooting: true,
        color: AppColors.error,
        barWidth: 2.5,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.error.withValues(alpha: 0.30),
              AppColors.warning.withValues(alpha: 0.05),
            ],
          ),
        ),
      ),
      // Soil moisture
      if (moistureSpots.isNotEmpty)
        LineChartBarData(
          spots: moistureSpots,
          isCurved: true,
          curveSmoothness: 0.2,
          preventCurveOverShooting: true,
          color: AppColors.accent,
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          dashArray: [6, 3],
        ),
      // ET
      if (normalizedEtSpots.isNotEmpty)
        LineChartBarData(
          spots: normalizedEtSpots,
          isCurved: true,
          curveSmoothness: 0.2,
          preventCurveOverShooting: true,
          color: AppColors.secondary,
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          dashArray: [3, 3],
        ),
    ];

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
              maxY: 1,
              clipData: const FlClipData.all(),
              lineBarsData: lines,
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: stressThreshold,
                    color: AppColors.warning.withValues(alpha: 0.7),
                    strokeWidth: 1,
                    dashArray: [8, 4],
                    label: HorizontalLineLabel(
                      show: true,
                      alignment: Alignment.topRight,
                      padding: const EdgeInsets.only(right: 4, bottom: 2),
                      style: AppTypography.chartAxis.copyWith(
                        color: AppColors.warning,
                      ),
                      labelResolver: (_) => 'Stress threshold',
                    ),
                  ),
                ],
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 0.25,
                getDrawingHorizontalLine: (v) => FlLine(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 0.25,
                    reservedSize: 36,
                    getTitlesWidget: (v, meta) => Text(
                      v.toStringAsFixed(2),
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
                    getTitlesWidget: (v, meta) {
                      final dt =
                          DateTime.fromMillisecondsSinceEpoch(v.toInt());
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          DateFormat.MMMd().format(dt),
                          style: AppTypography.chartAxis.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    },
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
                  getTooltipItems: (spots) {
                    final items = <LineTooltipItem?>[];
                    for (var i = 0; i < spots.length; i++) {
                      final spot = spots[i];
                      final dt = DateTime.fromMillisecondsSinceEpoch(
                          spot.x.toInt());
                      String label;
                      Color color;
                      String value;
                      if (i == 0) {
                        label = 'Stress';
                        color = AppColors.error;
                        value = spot.y.toStringAsFixed(2);
                      } else if (i == 1 && moistureSpots.isNotEmpty) {
                        label = 'Moisture';
                        color = AppColors.accent;
                        value = '${(spot.y * 100).toStringAsFixed(0)} %';
                      } else {
                        label = 'ET';
                        color = AppColors.secondary;
                        value =
                            '${(spot.y * etMax * 1.2).toStringAsFixed(1)} mm';
                      }
                      items.add(LineTooltipItem(
                        i == 0
                            ? '${DateFormat.MMMd().format(dt)}\n$label: $value'
                            : '$label: $value',
                        AppTypography.chartTooltip.copyWith(color: color),
                      ));
                    }
                    return items;
                  },
                ),
              ),
            ),
            duration: animate
                ? const Duration(milliseconds: 400)
                : Duration.zero,
          ),
        ),
        // Legend
        const SizedBox(height: 10),
        Wrap(
          spacing: 16,
          runSpacing: 4,
          children: [
            _legendDot('Stress', AppColors.error),
            if (moistureSpots.isNotEmpty)
              _legendDot('Soil Moisture', AppColors.accent),
            if (normalizedEtSpots.isNotEmpty)
              _legendDot('ET', AppColors.secondary),
          ],
        ),
      ],
    );
  }

  Widget _legendDot(String label, Color color) {
    return Builder(builder: (context) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    });
  }
}
