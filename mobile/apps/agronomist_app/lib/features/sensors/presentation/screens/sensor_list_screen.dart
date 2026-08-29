import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/sensor_bloc.dart';
import '../bloc/sensor_event.dart';
import '../bloc/sensor_state.dart';

class SensorListScreen extends StatefulWidget {
  const SensorListScreen({super.key, required this.fieldId});
  final String fieldId;

  @override
  State<SensorListScreen> createState() => _SensorListScreenState();
}

class _SensorListScreenState extends State<SensorListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SensorBloc>().add(LoadSensorReadings(fieldId: widget.fieldId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Sensors')),
      body: BlocBuilder<SensorBloc, SensorState>(
        builder: (context, state) {
          if (state is SensorLoading) return const Center(child: CircularProgressIndicator());
          if (state is SensorError) return Center(child: Text(state.message));
          if (state is SensorReadingsLoaded) {
            if (state.readings.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sensors, size: 80,
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
                    const SizedBox(height: 24),
                    Text('No sensor data', style: theme.textTheme.headlineSmall),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.readings.length,
              itemBuilder: (context, index) {
                final r = state.readings[index];
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  child: ListTile(
                    leading: Icon(
                      r.isOnline ? Icons.sensors : Icons.sensors_off,
                      color: r.isOnline ? Colors.green : theme.colorScheme.error,
                    ),
                    title: Text(r.sensorName),
                    subtitle: Text('${r.value.toStringAsFixed(1)} ${r.unit}'),
                    trailing: Text(r.type.name, style: theme.textTheme.labelSmall),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
