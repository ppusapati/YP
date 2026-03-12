import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// A single NDVI data point.
class NdviDataPoint {
  const NdviDataPoint({required this.date, required this.value});

  final DateTime date;

  /// NDVI value in the range 0.0 – 1.0.
  final double value;
}

/// An NDVI time-series line chart.
///
/// X-axis shows dates, Y-axis shows NDVI 0-1. The line gradient transitions
/// from red (low) to green (high). Touch interaction reveals a tooltip with
/// the date and value.
class NdviChart extends StatefulWidget {
  const NdviChart({
    super.key,
    required this.data,
    this.height = 220,
    this.showDots = true,
    this.animate = true,
  });

  final List<NdviDataPoint> data;
  final double height;
  final bool showDots;
  final bool animate;

  @override
  State<NdviChart> createState() => _NdviChartState();
}

class _NdviChartState extends State<NdviChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) return SizedBox(height: widget.height);

    final colorScheme = Theme.of(context).colorScheme;
    final sorted = List<NdviDataPoint>.from(widget.data)
      ..sort((a, b) => a.date.compareTo(b.date));

    final minEpoch = sorted.first.date.millisecondsSinceEpoch.toDouble();
    final maxEpoch = sorted.last.date.millisecondsSinceEpoch.toDouble();

    final spots = sorted.asMap().entries.map((e) {
      return FlSpot(
        e.value.date.millisecondsSinceEpoch.toDouble(),
        e.value.value,
      );
    }).toList();

    return SizedBox(
      height: widget.height,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 1,
          minX: minEpoch,
          maxX: maxEpoch,
          clipData: const FlClipData.all(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 0.2,
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
                interval: 0.2,
                reservedSize: 36,
                getTitlesWidget: (value, meta) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Text(
                    value.toStringAsFixed(1),
                    style: AppTypography.chartAxis.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: _xInterval(sorted),
                getTitlesWidget: (value, meta) {
                  final dt =
                      DateTime.fromMillisecondsSinceEpoch(value.toInt());
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
            handleBuiltInTouches: true,
            touchCallback: (event, response) {
              if (event is FlPointerExitEvent || response?.lineBarSpots == null) {
                setState(() => _touchedIndex = null);
              } else {
                setState(() => _touchedIndex = response?.lineBarSpots?.first.spotIndex);
              }
            },
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => colorScheme.surface,
              tooltipBorder: BorderSide(color: colorScheme.outlineVariant),
              tooltipRoundedRadius: 8,
              getTooltipItems: (spots) => spots.map((spot) {
                final dt =
                    DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
                return LineTooltipItem(
                  '${DateFormat.yMMMd().format(dt)}\n',
                  AppTypography.chartTooltip.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  children: [
                    TextSpan(
                      text: 'NDVI: ${spot.y.toStringAsFixed(2)}',
                      style: AppTypography.chartTooltip.copyWith(
                        color: AppColors.ndviColor(spot.y),
                        fontWeight: FontWeight.w700,
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
              curveSmoothness: 0.25,
              preventCurveOverShooting: true,
              barWidth: 3,
              isStrokeCapRound: true,
              gradient: const LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [AppColors.ndvi0, AppColors.ndvi40, AppColors.ndvi80],
                stops: [0.0, 0.4, 1.0],
              ),
              dotData: FlDotData(
                show: widget.showDots,
                getDotPainter: (spot, percent, bar, index) {
                  final isTouch = index == _touchedIndex;
                  return FlDotCirclePainter(
                    radius: isTouch ? 5 : 3,
                    color: AppColors.ndviColor(spot.y),
                    strokeWidth: 2,
                    strokeColor: colorScheme.surface,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.ndvi0.withValues(alpha: 0.05),
                    AppColors.ndvi80.withValues(alpha: 0.20),
                  ],
                ),
              ),
            ),
          ],
        ),
        duration: widget.animate
            ? const Duration(milliseconds: 400)
            : Duration.zero,
      ),
    );
  }

  double _xInterval(List<NdviDataPoint> sorted) {
    if (sorted.length < 2) return 1;
    final range = sorted.last.date.difference(sorted.first.date).inMilliseconds;
    // Aim for ~5 labels.
    return (range / 5).clamp(86400000, double.infinity); // min 1 day
  }
}
