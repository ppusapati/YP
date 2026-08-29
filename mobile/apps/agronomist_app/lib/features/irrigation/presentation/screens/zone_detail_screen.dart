import 'package:flutter/material.dart';

import '../../domain/entities/irrigation_zone_entity.dart';

/// Detail screen for an irrigation zone.
class ZoneDetailScreen extends StatelessWidget {
  const ZoneDetailScreen({super.key, required this.zone});
  final IrrigationZoneEntity zone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(zone.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(zone.name, style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 12),
                    _InfoRow(label: 'Status', value: zone.status.name),
                    const SizedBox(height: 8),
                    _InfoRow(label: 'Area', value: '${zone.areaHectares.toStringAsFixed(1)} ha'),
                    const SizedBox(height: 8),
                    _InfoRow(label: 'Flow Rate', value: '${zone.flowRate.toStringAsFixed(1)} L/min'),
                    const SizedBox(height: 8),
                    _InfoRow(label: 'Water Source', value: zone.waterSource),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant)),
        Text(value, style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500)),
      ],
    );
  }
}
