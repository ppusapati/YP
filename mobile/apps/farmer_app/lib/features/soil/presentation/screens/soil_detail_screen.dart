import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/soil_analysis_entity.dart';
import '../bloc/soil_bloc.dart';
import '../bloc/soil_event.dart';
import '../bloc/soil_state.dart';

class SoilDetailScreen extends StatefulWidget {
  const SoilDetailScreen({super.key, required this.fieldId});

  final String fieldId;

  @override
  State<SoilDetailScreen> createState() => _SoilDetailScreenState();
}

class _SoilDetailScreenState extends State<SoilDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SoilBloc>().add(LoadSoilHistory(fieldId: widget.fieldId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Soil History'),
      ),
      body: BlocBuilder<SoilBloc, SoilState>(
        builder: (context, state) {
          if (state is SoilLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SoilError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline,
                      size: 48, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context
                        .read<SoilBloc>()
                        .add(LoadSoilHistory(fieldId: widget.fieldId)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is SoilHistoryLoaded) {
            if (state.history.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.history,
                        size: 64,
                        color: colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.5)),
                    const SizedBox(height: 16),
                    Text('No historical data available',
                        style: theme.textTheme.titleMedium),
                  ],
                ),
              );
            }

            final sorted = List<SoilAnalysis>.from(state.history)
              ..sort((a, b) => a.analysisDate.compareTo(b.analysisDate));

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _NutrientHistoryChart(
                    title: 'pH History',
                    history: sorted,
                    valueExtractor: (a) => a.pH,
                    color: Colors.green,
                    minY: 3,
                    maxY: 10,
                  ),
                  const SizedBox(height: 24),
                  _NutrientHistoryChart(
                    title: 'Nitrogen (kg/ha)',
                    history: sorted,
                    valueExtractor: (a) => a.nitrogen,
                    color: Colors.green.shade700,
                    minY: 0,
                    maxY: 400,
                  ),
                  const SizedBox(height: 24),
                  _NutrientHistoryChart(
                    title: 'Phosphorus (kg/ha)',
                    history: sorted,
                    valueExtractor: (a) => a.phosphorus,
                    color: Colors.orange,
                    minY: 0,
                    maxY: 80,
                  ),
                  const SizedBox(height: 24),
                  _NutrientHistoryChart(
                    title: 'Potassium (kg/ha)',
                    history: sorted,
                    valueExtractor: (a) => a.potassium,
                    color: Colors.purple,
                    minY: 0,
                    maxY: 400,
                  ),
                  const SizedBox(height: 24),
                  _NutrientHistoryChart(
                    title: 'Organic Carbon (%)',
                    history: sorted,
                    valueExtractor: (a) => a.organicCarbon,
                    color: Colors.brown,
                    minY: 0,
                    maxY: 5,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Analysis Records',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...sorted.reversed.map((a) => _AnalysisRecordTile(
                        analysis: a,
                      )),
                  const SizedBox(height: 24),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _NutrientHistoryChart extends StatelessWidget {
  const _NutrientHistoryChart({
    required this.title,
    required this.history,
    required this.valueExtractor,
    required this.color,
    required this.minY,
    required this.maxY,
  });

  final String title;
  final List<SoilAnalysis> history;
  final double Function(SoilAnalysis) valueExtractor;
  final Color color;
  final double minY;
  final double maxY;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final spots = history.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), valueExtractor(entry.value));
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: LineChart(
            LineChartData(
              minY: minY,
              maxY: maxY,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: (maxY - minY) / 4,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 44,
                    getTitlesWidget: (value, meta) => Text(
                      value.toStringAsFixed(1),
                      style:
                          theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= history.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          DateFormat('MMM yy')
                              .format(history[index].analysisDate),
                          style: theme.textTheme.bodySmall
                              ?.copyWith(fontSize: 9),
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
                  color: color,
                  barWidth: 2.5,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: color.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AnalysisRecordTile extends StatelessWidget {
  const _AnalysisRecordTile({required this.analysis});

  final SoilAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
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
                  DateFormat('MMM dd, yyyy').format(analysis.analysisDate),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  analysis.fertilityRating,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: _ratingColor(analysis.fertilityRating),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 4,
              children: [
                _SmallStat(label: 'pH', value: analysis.pH.toStringAsFixed(1)),
                _SmallStat(
                    label: 'N',
                    value: '${analysis.nitrogen.toStringAsFixed(0)} kg/ha'),
                _SmallStat(
                    label: 'P',
                    value: '${analysis.phosphorus.toStringAsFixed(0)} kg/ha'),
                _SmallStat(
                    label: 'K',
                    value: '${analysis.potassium.toStringAsFixed(0)} kg/ha'),
                _SmallStat(
                    label: 'OC',
                    value: '${analysis.organicCarbon.toStringAsFixed(2)}%'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Color _ratingColor(String rating) {
    return switch (rating) {
      'Excellent' => Colors.green.shade700,
      'Good' => Colors.green,
      'Moderate' => Colors.orange,
      _ => Colors.red,
    };
  }
}

class _SmallStat extends StatelessWidget {
  const _SmallStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RichText(
      text: TextSpan(
        style: theme.textTheme.bodySmall,
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }
}
