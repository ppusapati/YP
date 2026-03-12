import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_typography.dart';

/// One time-series for a single sensor type.
class SensorSeries {
  const SensorSeries({
    required this.name,
    required this.color,
    required this.dataPoints,
    this.threshold,
  });

  final String name;
  final Color color;
  final List<SensorDataPoint> dataPoints;

  /// Optional horizontal threshold line.
  final double? threshold;
}

/// Single timestamped reading.
class SensorDataPoint {
  const SensorDataPoint({required this.timestamp, required this.value});
  final DateTime timestamp;
  final double value;
}

/// Predefined time range for the x-axis.
enum SensorTimeRange {
  hour('1H'),
  day('24H'),
  week('7D'),
  month('30D');

  const SensorTimeRange(this.label);
  final String label;

  Duration get duration => switch (this) {
        SensorTimeRange.hour => const Duration(hours: 1),
        SensorTimeRange.day => const Duration(hours: 24),
        SensorTimeRange.week => const Duration(days: 7),
        SensorTimeRange.month => const Duration(days: 30),
      };
}

/// A multi-series sensor data line chart with threshold lines and a
/// configurable time range selector.
class SensorChart extends StatefulWidget {
  const SensorChart({
    super.key,
    required this.series,
    this.height = 240,
    this.initialRange = SensorTimeRange.day,
    this.showRangeSelector = true,
    this.animate = true,
  });

  final List<SensorSeries> series;
  final double height;
  final SensorTimeRange initialRange;
  final bool showRangeSelector;
  final bool animate;

  @override
  State<SensorChart> createState() => _SensorChartState();
}

class _SensorChartState extends State<SensorChart> {
  late SensorTimeRange _range;

  @override
  void initState() {
    super.initState();
    _range = widget.initialRange;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (widget.series.isEmpty) return SizedBox(height: widget.height);

    final now = DateTime.now();
    final cutoff = now.subtract(_range.duration);
    final minX = cutoff.millisecondsSinceEpoch.toDouble();
    final maxX = now.millisecondsSinceEpoch.toDouble();

    // Compute y bounds across filtered data.
    double minY = double.infinity;
    double maxY = double.negativeInfinity;
    final lines = <LineChartBarData>[];

    for (final s in widget.series) {
      final filtered = s.dataPoints
          .where((p) => p.timestamp.isAfter(cutoff))
          .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

      for (final p in filtered) {
        if (p.value < minY) minY = p.value;
        if (p.value > maxY) maxY = p.value;
      }
      if (s.threshold != null) {
        if (s.threshold! < minY) minY = s.threshold!;
        if (s.threshold! > maxY) maxY = s.threshold!;
      }

      lines.add(LineChartBarData(
        spots: filtered
            .map((p) => FlSpot(
                  p.timestamp.millisecondsSinceEpoch.toDouble(),
                  p.value,
                ))
            .toList(),
        isCurved: true,
        curveSmoothness: 0.2,
        preventCurveOverShooting: true,
        color: s.color,
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          color: s.color.withValues(alpha: 0.08),
        ),
      ));
    }

    if (minY == double.infinity) minY = 0;
    if (maxY == double.negativeInfinity) maxY = 1;
    final yPadding = (maxY - minY) * 0.1;
    minY -= yPadding;
    maxY += yPadding;

    // Threshold extra lines.
    final extraLines = <HorizontalLine>[];
    for (final s in widget.series) {
      if (s.threshold != null) {
        extraLines.add(HorizontalLine(
          y: s.threshold!,
          color: s.color.withValues(alpha: 0.6),
          strokeWidth: 1,
          dashArray: [6, 4],
          label: HorizontalLineLabel(
            show: true,
            alignment: Alignment.topRight,
            padding: const EdgeInsets.only(right: 4, bottom: 2),
            style: AppTypography.chartAxis.copyWith(color: s.color),
            labelResolver: (_) => '${s.name} threshold',
          ),
        ));
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showRangeSelector) ...[
          _RangeSelector(
            selected: _range,
            onChanged: (r) => setState(() => _range = r),
          ),
          const SizedBox(height: 8),
        ],
        SizedBox(
          height: widget.height,
          child: LineChart(
            LineChartData(
              minX: minX,
              maxX: maxX,
              minY: minY,
              maxY: maxY,
              clipData: const FlClipData.all(),
              lineBarsData: lines,
              extraLinesData: ExtraLinesData(horizontalLines: extraLines),
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
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 42,
                    getTitlesWidget: (v, meta) => Text(
                      v.toStringAsFixed(1),
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
                      final fmt = _range == SensorTimeRange.hour ||
                              _range == SensorTimeRange.day
                          ? DateFormat.Hm()
                          : DateFormat.MMMd();
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          fmt.format(dt),
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
                  getTooltipItems: (spots) => spots.map((spot) {
                    final s = widget.series[spot.barIndex];
                    final dt =
                        DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
                    return LineTooltipItem(
                      '${s.name}: ${spot.y.toStringAsFixed(1)}\n',
                      AppTypography.chartTooltip.copyWith(color: s.color),
                      children: [
                        TextSpan(
                          text: DateFormat.yMMMd().add_Hm().format(dt),
                          style: AppTypography.chartAxis.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            duration: widget.animate
                ? const Duration(milliseconds: 400)
                : Duration.zero,
          ),
        ),
        // Legend
        if (widget.series.length > 1) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 4,
            children: widget.series.map((s) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: s.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    s.name,
                    style: AppTypography.labelSmall.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

class _RangeSelector extends StatelessWidget {
  const _RangeSelector({required this.selected, required this.onChanged});

  final SensorTimeRange selected;
  final ValueChanged<SensorTimeRange> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: SensorTimeRange.values.map((r) {
        final isSelected = r == selected;
        return Padding(
          padding: const EdgeInsets.only(left: 4),
          child: ChoiceChip(
            label: Text(r.label),
            selected: isSelected,
            onSelected: (_) => onChanged(r),
            selectedColor: colorScheme.primaryContainer,
            labelStyle: AppTypography.labelSmall.copyWith(
              color: isSelected
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        );
      }).toList(),
    );
  }
}
