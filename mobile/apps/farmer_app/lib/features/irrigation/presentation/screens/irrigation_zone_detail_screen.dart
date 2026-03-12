import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/irrigation_zone_entity.dart';
import '../bloc/irrigation_bloc.dart';
import '../bloc/irrigation_event.dart';
import '../bloc/irrigation_state.dart';
import '../widgets/moisture_indicator.dart';
import '../widgets/schedule_card.dart';
import 'irrigation_schedule_screen.dart';

class IrrigationZoneDetailScreen extends StatefulWidget {
  const IrrigationZoneDetailScreen({super.key, required this.zoneId});

  final String zoneId;

  @override
  State<IrrigationZoneDetailScreen> createState() =>
      _IrrigationZoneDetailScreenState();
}

class _IrrigationZoneDetailScreenState
    extends State<IrrigationZoneDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<IrrigationBloc>().add(LoadSchedule(zoneId: widget.zoneId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zone Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => BlocProvider.value(
                    value: context.read<IrrigationBloc>(),
                    child: IrrigationScheduleScreen(zoneId: widget.zoneId),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<IrrigationBloc, IrrigationState>(
        builder: (context, state) {
          if (state is IrrigationLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is IrrigationError) {
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
                        .read<IrrigationBloc>()
                        .add(LoadSchedule(zoneId: widget.zoneId)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is ScheduleLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MoistureSection(),
                  const SizedBox(height: 24),
                  Text(
                    'Moisture History',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _MoistureChart(),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Schedules',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => BlocProvider.value(
                                value: context.read<IrrigationBloc>(),
                                child: IrrigationScheduleScreen(
                                    zoneId: widget.zoneId),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.arrow_forward, size: 16),
                        label: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (state.schedules.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'No schedules for this zone',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                  else
                    ...state.schedules.take(3).map(
                          (s) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: ScheduleCard(schedule: s),
                          ),
                        ),
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

class _MoistureSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Demo values - in production these come from the zone entity
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade50,
            Colors.blue.shade100.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Moisture',
            style: theme.textTheme.titleSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          const MoistureIndicator(
            currentMoisture: 65,
            targetMoisture: 80,
            height: 16,
          ),
        ],
      ),
    );
  }
}

class _MoistureChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Sample data for moisture over time
    final spots = <FlSpot>[
      const FlSpot(0, 72),
      const FlSpot(1, 68),
      const FlSpot(2, 65),
      const FlSpot(3, 80),
      const FlSpot(4, 76),
      const FlSpot(5, 71),
      const FlSpot(6, 65),
    ];

    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minY: 40,
          maxY: 100,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 20,
            getDrawingHorizontalLine: (value) => FlLine(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
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
                reservedSize: 40,
                getTitlesWidget: (value, meta) => Text(
                  '${value.toInt()}%',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= days.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      days[index],
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
              color: Colors.blue,
              barWidth: 2.5,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withValues(alpha: 0.1),
              ),
            ),
            // Target line
            LineChartBarData(
              spots: List.generate(7, (i) => FlSpot(i.toDouble(), 80)),
              isCurved: false,
              color: Colors.orange.withValues(alpha: 0.6),
              barWidth: 1,
              dotData: const FlDotData(show: false),
              dashArray: [5, 5],
            ),
          ],
        ),
      ),
    );
  }
}
