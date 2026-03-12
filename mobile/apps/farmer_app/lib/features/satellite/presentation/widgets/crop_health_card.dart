import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/crop_health_entity.dart';

/// Card displaying a summary of crop health status for a field.
class CropHealthCard extends StatelessWidget {
  const CropHealthCard({
    super.key,
    required this.cropHealth,
    this.onTap,
  });

  final CropHealthEntity cropHealth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusColor = _statusColor(cropHealth.overallStatus);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _statusIcon(cropHealth.overallStatus),
                      color: statusColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cropHealth.fieldName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Updated ${DateFormat('MMM d, y').format(cropHealth.lastUpdated)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      cropHealth.overallStatus.displayName,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _MetricItem(
                    label: 'Current NDVI',
                    value: cropHealth.currentNdvi.toStringAsFixed(3),
                    color: statusColor,
                  ),
                  _MetricItem(
                    label: 'Trend',
                    value:
                        '${cropHealth.isImproving ? '+' : ''}${cropHealth.trendPercent.toStringAsFixed(1)}%',
                    color: cropHealth.isImproving ? Colors.green : Colors.red,
                  ),
                  _MetricItem(
                    label: 'Data Points',
                    value: '${cropHealth.timeSeries.length}',
                    color: colorScheme.primary,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // NDVI progress bar.
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: cropHealth.currentNdvi.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Color _statusColor(CropHealthStatus status) {
    return switch (status) {
      CropHealthStatus.excellent => const Color(0xFF006400),
      CropHealthStatus.good => Colors.green,
      CropHealthStatus.moderate => Colors.orange,
      CropHealthStatus.stressed => Colors.deepOrange,
      CropHealthStatus.critical => Colors.red,
    };
  }

  static IconData _statusIcon(CropHealthStatus status) {
    return switch (status) {
      CropHealthStatus.excellent => Icons.eco,
      CropHealthStatus.good => Icons.grass,
      CropHealthStatus.moderate => Icons.warning_amber,
      CropHealthStatus.stressed => Icons.report_problem,
      CropHealthStatus.critical => Icons.dangerous,
    };
  }
}

class _MetricItem extends StatelessWidget {
  const _MetricItem({
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
          style: theme.textTheme.titleSmall?.copyWith(
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
