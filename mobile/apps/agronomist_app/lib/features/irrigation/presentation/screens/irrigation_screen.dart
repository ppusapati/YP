import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/irrigation_zone_entity.dart';
import '../bloc/irrigation_bloc.dart';
import '../bloc/irrigation_event.dart';
import '../bloc/irrigation_state.dart';

/// Screen showing irrigation zones for a field.
class IrrigationScreen extends StatefulWidget {
  const IrrigationScreen({super.key, required this.fieldId});
  final String fieldId;

  @override
  State<IrrigationScreen> createState() => _IrrigationScreenState();
}

class _IrrigationScreenState extends State<IrrigationScreen> {
  @override
  void initState() {
    super.initState();
    context.read<IrrigationBloc>().add(LoadIrrigationZones(fieldId: widget.fieldId));
  }

  Color _statusColor(IrrigationZoneStatus status, ColorScheme cs) => switch (status) {
    IrrigationZoneStatus.irrigating => Colors.blue,
    IrrigationZoneStatus.active => Colors.green,
    IrrigationZoneStatus.scheduled => Colors.orange,
    IrrigationZoneStatus.error => cs.error,
    IrrigationZoneStatus.inactive => cs.onSurfaceVariant,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Irrigation')),
      body: BlocBuilder<IrrigationBloc, IrrigationState>(
        builder: (context, state) {
          if (state is IrrigationLoading) return const Center(child: CircularProgressIndicator());
          if (state is IrrigationError) return Center(child: Text(state.message));
          if (state is IrrigationZonesLoaded) {
            if (state.zones.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.water_drop, size: 80,
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
                    const SizedBox(height: 24),
                    Text('No irrigation zones', style: theme.textTheme.headlineSmall),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.zones.length,
              itemBuilder: (context, index) {
                final zone = state.zones[index];
                final color = _statusColor(zone.status, theme.colorScheme);
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.water_drop, color: color),
                    title: Text(zone.name),
                    subtitle: Text('${zone.areaHectares.toStringAsFixed(1)} ha - ${zone.status.name}'),
                    trailing: Text('${zone.flowRate.toStringAsFixed(1)} L/min',
                        style: theme.textTheme.bodySmall),
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
