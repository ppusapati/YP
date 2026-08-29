import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/stress_alert_entity.dart';

/// A card displaying a stress alert from satellite monitoring.
class StressAlertCard extends StatelessWidget {
  const StressAlertCard({super.key, required this.alert, this.onTap});

  final StressAlertEntity alert;
  final VoidCallback? onTap;

  Color _severityColor(ColorScheme colorScheme) {
    return switch (alert.severity) {
      StressSeverity.critical => colorScheme.error,
      StressSeverity.high => Colors.deepOrange,
      StressSeverity.medium => Colors.orange,
      StressSeverity.low => Colors.green,
    };
  }

  IconData _stressIcon() {
    return switch (alert.stressType) {
      StressType.water => Icons.water_drop,
      StressType.nutrient => Icons.science,
      StressType.disease => Icons.coronavirus,
      StressType.heat => Icons.thermostat,
      StressType.frost => Icons.ac_unit,
      StressType.unknown => Icons.warning,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = _severityColor(colorScheme);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.5)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_stressIcon(), color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.stressType.displayName,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${alert.severity.displayName} - ${alert.confidencePercent} confidence',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '${alert.affectedAreaFormatted} affected - ${DateFormat.yMMMd().format(alert.detectedAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
