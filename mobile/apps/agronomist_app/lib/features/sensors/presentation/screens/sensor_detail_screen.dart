import 'package:flutter/material.dart';

import '../../domain/entities/sensor_reading_entity.dart';

class SensorDetailScreen extends StatelessWidget {
  const SensorDetailScreen({super.key, required this.reading});
  final SensorReadingEntity reading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(reading.sensorName)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(reading.sensorName, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 16),
                Text('Type: ${reading.type.name}', style: theme.textTheme.bodyMedium),
                const SizedBox(height: 8),
                Text('Value: ${reading.value.toStringAsFixed(2)} ${reading.unit}',
                    style: theme.textTheme.bodyMedium),
                const SizedBox(height: 8),
                Text('Status: ${reading.isOnline ? "Online" : "Offline"}',
                    style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
