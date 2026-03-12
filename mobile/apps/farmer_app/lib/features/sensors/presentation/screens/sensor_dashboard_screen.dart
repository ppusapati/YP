import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/sensor_entity.dart';
import '../bloc/sensor_bloc.dart';
import '../bloc/sensor_event.dart';
import '../bloc/sensor_state.dart';
import '../widgets/sensor_card.dart';
import 'sensor_detail_screen.dart';

class SensorDashboardScreen extends StatefulWidget {
  const SensorDashboardScreen({super.key});

  static const String routePath = '/sensors';

  @override
  State<SensorDashboardScreen> createState() => _SensorDashboardScreenState();
}

class _SensorDashboardScreenState extends State<SensorDashboardScreen> {
  SensorType? _selectedFilter;

  @override
  void initState() {
    super.initState();
    context.read<SensorBloc>().add(const LoadSensors());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor Monitoring'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<SensorBloc>().add(const LoadSensors());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _FilterChips(
            selectedType: _selectedFilter,
            onSelected: (type) {
              setState(() => _selectedFilter = type);
              context.read<SensorBloc>().add(FilterByType(type: type));
            },
          ),
          Expanded(
            child: BlocBuilder<SensorBloc, SensorState>(
              builder: (context, state) {
                if (state is SensorLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is SensorError) {
                  return _ErrorView(
                    message: state.message,
                    onRetry: () {
                      context.read<SensorBloc>().add(const LoadSensors());
                    },
                  );
                }
                if (state is SensorsLoaded) {
                  if (state.sensors.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.sensors_off,
                            size: 64,
                            color: colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No sensors found',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<SensorBloc>().add(const LoadSensors());
                    },
                    child: Column(
                      children: [
                        _SensorSummaryBar(
                          total: state.sensors.length,
                          online: state.onlineCount,
                          offline: state.offlineCount,
                          lowBattery: state.lowBatteryCount,
                        ),
                        Expanded(
                          child: GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.85,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: state.sensors.length,
                            itemBuilder: (context, index) {
                              final sensor = state.sensors[index];
                              return SensorCard(
                                sensor: sensor,
                                onTap: () => _navigateToDetail(sensor),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(Sensor sensor) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: context.read<SensorBloc>(),
          child: SensorDetailScreen(sensorId: sensor.id),
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.selectedType,
    required this.onSelected,
  });

  final SensorType? selectedType;
  final ValueChanged<SensorType?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          FilterChip(
            label: const Text('All'),
            selected: selectedType == null,
            onSelected: (_) => onSelected(null),
          ),
          const SizedBox(width: 8),
          ...SensorType.values.map((type) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(_typeLabel(type)),
                selected: selectedType == type,
                onSelected: (_) => onSelected(type),
              ),
            );
          }),
        ],
      ),
    );
  }

  String _typeLabel(SensorType type) {
    return switch (type) {
      SensorType.temperature => 'Temp',
      SensorType.humidity => 'Humidity',
      SensorType.soilMoisture => 'Moisture',
      SensorType.light => 'Light',
      SensorType.windSpeed => 'Wind',
      SensorType.rainfall => 'Rain',
      SensorType.pressure => 'Pressure',
    };
  }
}

class _SensorSummaryBar extends StatelessWidget {
  const _SensorSummaryBar({
    required this.total,
    required this.online,
    required this.offline,
    required this.lowBattery,
  });

  final int total;
  final int online;
  final int offline;
  final int lowBattery;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryItem(label: 'Total', value: '$total', color: colorScheme.primary),
          _SummaryItem(label: 'Online', value: '$online', color: Colors.green),
          _SummaryItem(label: 'Offline', value: '$offline', color: Colors.grey),
          _SummaryItem(
            label: 'Low Batt',
            value: '$lowBattery',
            color: Colors.orange,
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
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Failed to load sensors',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
