import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/yield_prediction_entity.dart';
import '../bloc/yield_bloc.dart';
import '../bloc/yield_event.dart';
import '../bloc/yield_state.dart';
import '../widgets/yield_prediction_card.dart';
import 'yield_detail_screen.dart';

class YieldDashboardScreen extends StatefulWidget {
  const YieldDashboardScreen({super.key});

  static const String routePath = '/yield';

  @override
  State<YieldDashboardScreen> createState() => _YieldDashboardScreenState();
}

class _YieldDashboardScreenState extends State<YieldDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<YieldBloc>().add(const LoadPredictions());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yield Predictions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<YieldBloc>().add(const LoadPredictions()),
          ),
        ],
      ),
      body: BlocBuilder<YieldBloc, YieldState>(
        builder: (context, state) {
          if (state is YieldLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is YieldError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline,
                      size: 48, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text(state.message, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context
                        .read<YieldBloc>()
                        .add(const LoadPredictions()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is PredictionsLoaded) {
            if (state.predictions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.agriculture,
                        size: 64,
                        color: colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.5)),
                    const SizedBox(height: 16),
                    Text('No yield predictions available',
                        style: theme.textTheme.titleMedium),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<YieldBloc>().add(const LoadPredictions());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SummaryHeader(state: state),
                    const SizedBox(height: 20),
                    if (state.uniqueCropTypes.length > 1) ...[
                      _CropFilterChips(
                        crops: state.uniqueCropTypes,
                        selectedCrop: state.selectedCropType,
                        onSelected: (crop) {
                          context
                              .read<YieldBloc>()
                              .add(SelectCrop(cropType: crop));
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    Text(
                      'Yield by Crop',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _YieldBarChart(predictions: state.predictions),
                    const SizedBox(height: 24),
                    Text(
                      'Predictions',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...state.predictions.map(
                      (p) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: YieldPredictionCard(
                          prediction: p,
                          onTap: () => _navigateToDetail(p),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _navigateToDetail(YieldPrediction prediction) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: context.read<YieldBloc>(),
          child: YieldDetailScreen(prediction: prediction),
        ),
      ),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({required this.state});

  final PredictionsLoaded state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primaryContainer.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryItem(
            label: 'Total Predictions',
            value: '${state.predictions.length}',
            icon: Icons.analytics,
            color: colorScheme.onPrimaryContainer,
          ),
          _SummaryItem(
            label: 'Harvest Soon',
            value: '${state.harvestSoonCount}',
            icon: Icons.timer,
            color: Colors.orange,
          ),
          _SummaryItem(
            label: 'Crop Types',
            value: '${state.uniqueCropTypes.length}',
            icon: Icons.grass,
            color: Colors.green,
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: color.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

class _CropFilterChips extends StatelessWidget {
  const _CropFilterChips({
    required this.crops,
    required this.selectedCrop,
    required this.onSelected,
  });

  final List<String> crops;
  final String? selectedCrop;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: crops.map((crop) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(crop),
              selected: selectedCrop == crop,
              onSelected: (_) => onSelected(crop),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _YieldBarChart extends StatelessWidget {
  const _YieldBarChart({required this.predictions});

  final List<YieldPrediction> predictions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Group by crop type
    final grouped = <String, double>{};
    for (final p in predictions) {
      grouped[p.cropType] = (grouped[p.cropType] ?? 0) + p.expectedYield;
    }
    final entries = grouped.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (entries.isEmpty) return const SizedBox.shrink();

    final maxY = entries.first.value * 1.2;
    final colors = [
      Colors.amber,
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.orange,
      Colors.teal,
    ];

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
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
                reservedSize: 48,
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
                  if (index < 0 || index >= entries.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      entries[index].key,
                      style:
                          theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: entries.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.value,
                  color: colors[entry.key % colors.length],
                  width: 24,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
