import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/yield_prediction_entity.dart';
import '../bloc/yield_bloc.dart';
import '../bloc/yield_event.dart';
import '../bloc/yield_state.dart';
import '../widgets/harvest_countdown.dart';
import '../widgets/yield_factor_list.dart';

class YieldDetailScreen extends StatefulWidget {
  const YieldDetailScreen({super.key, required this.prediction});

  final YieldPrediction prediction;

  @override
  State<YieldDetailScreen> createState() => _YieldDetailScreenState();
}

class _YieldDetailScreenState extends State<YieldDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<YieldBloc>().add(LoadHistory(
          fieldId: widget.prediction.fieldId,
          cropType: widget.prediction.cropType,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final prediction = widget.prediction;

    return Scaffold(
      appBar: AppBar(
        title: Text(prediction.cropType),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HarvestCountdown(
              harvestDate: prediction.harvestDate,
              cropType: prediction.cropType,
            ),
            const SizedBox(height: 24),
            _PredictionDetails(prediction: prediction),
            const SizedBox(height: 24),
            _ConfidenceSection(prediction: prediction),
            const SizedBox(height: 24),
            Text(
              'Impact Factors',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: YieldFactorList(factors: prediction.factors),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Yield History',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            BlocBuilder<YieldBloc, YieldState>(
              builder: (context, state) {
                if (state is YieldLoading) {
                  return const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (state is YieldHistoryLoaded && state.history.isNotEmpty) {
                  return _HistoryChart(history: state.history);
                }
                return SizedBox(
                  height: 120,
                  child: Center(
                    child: Text(
                      'No historical data available',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _PredictionDetails extends StatelessWidget {
  const _PredictionDetails({required this.prediction});

  final YieldPrediction prediction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _DetailColumn(
                  label: 'Expected Yield',
                  value:
                      '${prediction.expectedYield.toStringAsFixed(1)} ${prediction.unit}',
                  valueStyle: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary,
                  ),
                ),
                if (prediction.previousYield != null)
                  _DetailColumn(
                    label: 'Previous Yield',
                    value:
                        '${prediction.previousYield!.toStringAsFixed(1)} ${prediction.unit}',
                    crossAxisAlignment: CrossAxisAlignment.end,
                  ),
              ],
            ),
            if (prediction.yieldChangePercent != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (prediction.yieldChangePercent! >= 0
                          ? Colors.green
                          : Colors.red)
                      .withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      prediction.yieldChangePercent! >= 0
                          ? Icons.trending_up
                          : Icons.trending_down,
                      color: prediction.yieldChangePercent! >= 0
                          ? Colors.green
                          : Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${prediction.yieldChangePercent! >= 0 ? '+' : ''}${prediction.yieldChangePercent!.toStringAsFixed(1)}% vs previous season',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: prediction.yieldChangePercent! >= 0
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _DetailColumn(
                  label: 'Harvest Date',
                  value:
                      DateFormat('MMM dd, yyyy').format(prediction.harvestDate),
                ),
                _DetailColumn(
                  label: 'Field',
                  value: prediction.fieldName ?? prediction.fieldId,
                  crossAxisAlignment: CrossAxisAlignment.end,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailColumn extends StatelessWidget {
  const _DetailColumn({
    required this.label,
    required this.value,
    this.valueStyle,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  final String label;
  final String value;
  final TextStyle? valueStyle;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: valueStyle ??
              theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _ConfidenceSection extends StatelessWidget {
  const _ConfidenceSection({required this.prediction});

  final YieldPrediction prediction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final confidence = prediction.confidenceLevel;
    final color = confidence >= 0.85
        ? Colors.green
        : confidence >= 0.65
            ? Colors.orange
            : Colors.red;

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Confidence Level',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${(confidence * 100).toStringAsFixed(0)}% - ${prediction.confidenceLabel}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: confidence,
                minHeight: 10,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _confidenceDescription(confidence),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _confidenceDescription(double level) {
    if (level >= 0.85) {
      return 'High confidence prediction based on comprehensive data from multiple sources.';
    }
    if (level >= 0.65) {
      return 'Moderate confidence. Some data gaps may affect prediction accuracy.';
    }
    return 'Low confidence due to limited data. Consider collecting more field observations.';
  }
}

class _HistoryChart extends StatelessWidget {
  const _HistoryChart({required this.history});

  final List<YieldPrediction> history;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final sorted = List<YieldPrediction>.from(history)
      ..sort((a, b) => a.harvestDate.compareTo(b.harvestDate));

    final spots = sorted.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.expectedYield);
    }).toList();

    final maxY = sorted
            .map((h) => h.expectedYield)
            .reduce((a, b) => a > b ? a : b) *
        1.2;

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
            getDrawingHorizontalLine: (value) => FlLine(
              color: colorScheme.outlineVariant.withValues(alpha: 0.4),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 44,
                getTitlesWidget: (value, meta) => Text(
                  value.toStringAsFixed(0),
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= sorted.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      DateFormat('yyyy')
                          .format(sorted[index].harvestDate),
                      style:
                          theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: colorScheme.primary,
              barWidth: 2.5,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: colorScheme.primary.withValues(alpha: 0.1),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final index = spot.spotIndex;
                  final p = sorted[index];
                  return LineTooltipItem(
                    '${p.expectedYield.toStringAsFixed(1)} ${p.unit}\n${DateFormat('MMM yyyy').format(p.harvestDate)}',
                    TextStyle(
                      color: colorScheme.onInverseSurface,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }
}
