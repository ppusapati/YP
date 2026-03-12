import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/soil_analysis_entity.dart';
import '../bloc/soil_bloc.dart';
import '../bloc/soil_event.dart';
import '../bloc/soil_state.dart';
import '../widgets/nutrient_gauge.dart';
import '../widgets/ph_indicator.dart';
import '../widgets/soil_summary_card.dart';
import 'soil_detail_screen.dart';

class SoilDashboardScreen extends StatefulWidget {
  const SoilDashboardScreen({super.key, required this.fieldId});

  final String fieldId;
  static const String routePath = '/soil';

  @override
  State<SoilDashboardScreen> createState() => _SoilDashboardScreenState();
}

class _SoilDashboardScreenState extends State<SoilDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SoilBloc>().add(LoadSoilAnalysis(fieldId: widget.fieldId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Soil Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context
                  .read<SoilBloc>()
                  .add(LoadSoilAnalysis(fieldId: widget.fieldId));
            },
          ),
        ],
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
                  Text(state.message, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context
                        .read<SoilBloc>()
                        .add(LoadSoilAnalysis(fieldId: widget.fieldId)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is SoilAnalysisLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<SoilBloc>()
                    .add(LoadSoilAnalysis(fieldId: widget.fieldId));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SoilSummaryCard(
                      analysis: state.analysis,
                      onTap: () => _navigateToDetail(state.analysis),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'pH Level',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    PhIndicator(pH: state.analysis.pH),
                    const SizedBox(height: 24),
                    Text(
                      'Nutrient Levels',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _NutrientGaugesRow(analysis: state.analysis),
                    const SizedBox(height: 24),
                    Text(
                      'Nutrient Radar',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _NutrientRadarChart(analysis: state.analysis),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _navigateToDetail(state.analysis),
                        icon: const Icon(Icons.analytics),
                        label: const Text('View Detailed History'),
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

  void _navigateToDetail(SoilAnalysis analysis) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: context.read<SoilBloc>(),
          child: SoilDetailScreen(fieldId: analysis.fieldId),
        ),
      ),
    );
  }
}

class _NutrientGaugesRow extends StatelessWidget {
  const _NutrientGaugesRow({required this.analysis});

  final SoilAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        NutrientGauge(
          label: 'Nitrogen',
          value: analysis.nitrogen,
          unit: 'kg/ha',
          maxValue: 400,
          optimalMin: 150,
          optimalMax: 300,
          color: Colors.green,
          size: 80,
        ),
        NutrientGauge(
          label: 'Phosphorus',
          value: analysis.phosphorus,
          unit: 'kg/ha',
          maxValue: 80,
          optimalMin: 20,
          optimalMax: 50,
          color: Colors.orange,
          size: 80,
        ),
        NutrientGauge(
          label: 'Potassium',
          value: analysis.potassium,
          unit: 'kg/ha',
          maxValue: 400,
          optimalMin: 150,
          optimalMax: 300,
          color: Colors.purple,
          size: 80,
        ),
        NutrientGauge(
          label: 'Organic C',
          value: analysis.organicCarbon,
          unit: '%',
          maxValue: 5,
          optimalMin: 1.5,
          optimalMax: 3.0,
          color: Colors.brown,
          size: 80,
        ),
      ],
    );
  }
}

class _NutrientRadarChart extends StatelessWidget {
  const _NutrientRadarChart({required this.analysis});

  final SoilAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Normalize values to 0-1 scale for radar chart
    final normalizedN = (analysis.nitrogen / 400).clamp(0.0, 1.0);
    final normalizedP = (analysis.phosphorus / 80).clamp(0.0, 1.0);
    final normalizedK = (analysis.potassium / 400).clamp(0.0, 1.0);
    final normalizedOC = (analysis.organicCarbon / 5).clamp(0.0, 1.0);
    final normalizedPH = (1.0 - (analysis.pH - 6.5).abs() / 6.5).clamp(0.0, 1.0);

    return SizedBox(
      height: 240,
      child: RadarChart(
        RadarChartData(
          radarShape: RadarShape.polygon,
          titlePositionPercentageOffset: 0.2,
          dataSets: [
            RadarDataSet(
              fillColor: colorScheme.primary.withValues(alpha: 0.15),
              borderColor: colorScheme.primary,
              borderWidth: 2,
              entryRadius: 3,
              dataEntries: [
                RadarEntry(value: normalizedN * 100),
                RadarEntry(value: normalizedP * 100),
                RadarEntry(value: normalizedK * 100),
                RadarEntry(value: normalizedOC * 100),
                RadarEntry(value: normalizedPH * 100),
              ],
            ),
          ],
          getTitle: (index, angle) {
            const titles = ['N', 'P', 'K', 'OC', 'pH'];
            return RadarChartTitle(
              text: titles[index],
              angle: 0,
            );
          },
          tickCount: 4,
          ticksTextStyle: theme.textTheme.bodySmall?.copyWith(
                fontSize: 8,
                color: colorScheme.onSurfaceVariant,
              ) ??
              const TextStyle(fontSize: 8),
          tickBorderData: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
          gridBorderData: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          borderData: FlBorderData(show: false),
          radarBorderData:
              BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
      ),
    );
  }
}
