import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/alert_entity.dart';
import 'severity_icon.dart';

/// Severity-colored card for displaying an alert in a feed.
///
/// Colors: red = emergency, orange = critical, yellow = warning, blue = info.
class AlertCard extends StatelessWidget {
  const AlertCard({
    super.key,
    required this.alert,
    this.onTap,
  });

  final Alert alert;
  final VoidCallback? onTap;

  IconData _iconForType(AlertType type) {
    switch (type) {
      case AlertType.cropStress:
        return Icons.grass;
      case AlertType.waterShortage:
        return Icons.water_drop_outlined;
      case AlertType.diseaseOutbreak:
        return Icons.coronavirus_outlined;
      case AlertType.pestOutbreak:
        return Icons.bug_report_outlined;
      case AlertType.irrigationNeeded:
        return Icons.shower_outlined;
      case AlertType.frostWarning:
        return Icons.ac_unit;
      case AlertType.soilHealth:
        return Icons.landscape_outlined;
      case AlertType.weatherEvent:
        return Icons.thunderstorm_outlined;
    }
  }

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final severityColor = SeverityIcon.colorForSeverity(alert.severity);
    final bgColor = SeverityIcon.backgroundColorForSeverity(alert.severity);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: severityColor, width: 4),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: bgColor.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      _iconForType(alert.type),
                      color: severityColor,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: severityColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              alert.severity.displayName.toUpperCase(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: severityColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _formatTimeAgo(alert.timestamp),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (!alert.read) ...[
                            const SizedBox(width: 6),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: severityColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        alert.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight:
                              alert.read ? FontWeight.w500 : FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (alert.fieldName != null) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              Icons.place_outlined,
                              size: 14,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              alert.fieldName!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        alert.message,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (alert.status != AlertStatus.active) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            alert.status.displayName,
                            style: theme.textTheme.labelSmall,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
