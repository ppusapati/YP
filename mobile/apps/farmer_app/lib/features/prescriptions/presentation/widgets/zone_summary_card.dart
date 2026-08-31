import 'package:flutter/material.dart';

import '../../domain/entities/prescription_entity.dart';

/// Card per zone (Low/Med/High) showing area, mean rate, total amount
/// with zone color coding.
class ZoneSummaryCard extends StatelessWidget {
  const ZoneSummaryCard({
    super.key,
    required this.zone,
    this.unit = '',
  });

  final ZoneSummary zone;
  final String unit;

  Color _zoneColor() {
    final z = zone.zone.toLowerCase();
    if (z == 'low') return Colors.green;
    if (z == 'medium' || z == 'med') return Colors.orange;
    if (z == 'high') return Colors.red;
    return Colors.blueGrey;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = _zoneColor();

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.4)),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: color, width: 4),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Zone label
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  zone.zone.substring(0, 1).toUpperCase(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Zone info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${zone.zone[0].toUpperCase()}${zone.zone.substring(1)} Zone',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${zone.areaHectares.toStringAsFixed(1)} ha',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              // Rate and amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${zone.meanRate.toStringAsFixed(1)} $unit/ha',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${zone.minRate.toStringAsFixed(0)}-${zone.maxRate.toStringAsFixed(0)} range',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Total: ${zone.totalAmount.toStringAsFixed(0)} $unit',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
