import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/crop_health_entity.dart';
import '../bloc/satellite_bloc.dart';
import '../bloc/satellite_event.dart';
import '../bloc/satellite_state.dart';
import '../widgets/crop_health_card.dart';

/// Dashboard screen showing NDVI history charts, crop growth, and stress data.
class CropHealthDashboardScreen extends StatefulWidget {
  const CropHealthDashboardScreen({
    super.key,
    required this.fieldId,
    this.fieldName,
  });

  final String fieldId;
  final String? fieldName;

  static const String routePath = '/satellite/:fieldId/health';

  @override
  State<CropHealthDashboardScreen> createState() =>
      _CropHealthDashboardScreenState();
}

class _CropHealthDashboardScreenState extends State<CropHealthDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<SatelliteBloc>()
        .add(LoadCropHealth(fieldId: widget.fieldId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fieldName ?? 'Crop Health'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context
                  .read<SatelliteBloc>()
                  .add(LoadCropHealth(fieldId: widget.fieldId));
            },
          ),
        ],
      ),
      body: BlocBuilder<SatelliteBloc, SatelliteState>(
        builder: (context, state) {
          if (state is SatelliteLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SatelliteError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline,
                      size: 48, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text(state.message, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      context.read<SatelliteBloc>().add(
                            LoadCropHealth(fieldId: widget.fieldId),
                          );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is CropHealthLoaded) {
            return _buildDashboard(context, state.cropHealth);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, CropHealthEntity health) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CropHealthCard(cropHealth: health),
          const SizedBox(height: 24),
          Text(
            'NDVI History',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 250,
            child: _NdviChart(timeSeries: health.timeSeries),
          ),
          const SizedBox(height: 24),
          Text(
            'Growth Rate',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: _GrowthRateChart(timeSeries: health.timeSeries),
          ),
          const SizedBox(height: 24),
          Text(
            'NDVI Range',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: _NdviRangeChart(timeSeries: health.timeSeries),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _NdviChart extends StatelessWidget {
  const _NdviChart({required this.timeSeries});

  final List<CropHealthDataPoint> timeSeries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (timeSeries.isEmpty) {
      return Center(
        child: Text(
          'No NDVI data available',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final spots = timeSeries.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.ndviMean);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 0.2,
          getDrawingHorizontalLine: (value) => FlLine(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(1),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: (timeSeries.length / 5).ceilToDouble().clamp(1, 100),
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < timeSeries.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      DateFormat('M/d')
                          .format(timeSeries[index].date),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minY: 0,
        maxY: 1,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.green.shade700,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.green.withValues(alpha: 0.15),
            ),
          ),
        ],
      ),
    );
  }
}

class _GrowthRateChart extends StatelessWidget {
  const _GrowthRateChart({required this.timeSeries});

  final List<CropHealthDataPoint> timeSeries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (timeSeries.isEmpty) {
      return Center(
        child: Text(
          'No growth data available',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final barGroups = timeSeries.asMap().entries.map((entry) {
      final rate = entry.value.growthRate;
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: rate,
            color: rate >= 0 ? Colors.green : Colors.red,
            width: 8,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toStringAsFixed(0)}%',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                );
              },
            ),
          ),
          bottomTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: barGroups,
      ),
    );
  }
}

class _NdviRangeChart extends StatelessWidget {
  const _NdviRangeChart({required this.timeSeries});

  final List<CropHealthDataPoint> timeSeries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (timeSeries.isEmpty) {
      return Center(
        child: Text(
          'No NDVI range data available',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final meanSpots = timeSeries.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.ndviMean);
    }).toList();

    final minSpots = timeSeries.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.ndviMin);
    }).toList();

    final maxSpots = timeSeries.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.ndviMax);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(1),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                );
              },
            ),
          ),
          bottomTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minY: 0,
        maxY: 1,
        lineBarsData: [
          LineChartBarData(
            spots: maxSpots,
            isCurved: true,
            color: Colors.green.withValues(alpha: 0.4),
            barWidth: 1,
            dotData: const FlDotData(show: false),
          ),
          LineChartBarData(
            spots: meanSpots,
            isCurved: true,
            color: Colors.green.shade700,
            barWidth: 2.5,
            dotData: const FlDotData(show: false),
          ),
          LineChartBarData(
            spots: minSpots,
            isCurved: true,
            color: Colors.orange.withValues(alpha: 0.6),
            barWidth: 1,
            dotData: const FlDotData(show: false),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final labels = ['Max', 'Mean', 'Min'];
                final label =
                    spot.barIndex < labels.length ? labels[spot.barIndex] : '';
                return LineTooltipItem(
                  '$label: ${spot.y.toStringAsFixed(3)}',
                  theme.textTheme.labelSmall!.copyWith(
                    color: colorScheme.onSurface,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}
