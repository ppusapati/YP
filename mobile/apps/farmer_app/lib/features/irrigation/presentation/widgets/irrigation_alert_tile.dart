import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/irrigation_alert_entity.dart';

class IrrigationAlertTile extends StatelessWidget {
  const IrrigationAlertTile({
    super.key,
    required this.alert,
    this.onTap,
    this.onDismiss,
  });

  final IrrigationAlert alert;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final (severityColor, severityIcon) = _severityDisplay(alert.severity);
    final timeAgo = _formatTimeAgo(alert.timestamp);

    return Dismissible(
      key: Key(alert.id),
      direction:
          onDismiss != null ? DismissDirection.endToStart : DismissDirection.none,
      onDismissed: (_) => onDismiss?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: colorScheme.error,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: severityColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(severityIcon, color: severityColor, size: 20),
        ),
        title: Text(
          alert.message,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: alert.isRead ? FontWeight.normal : FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            Text(
              _alertTypeLabel(alert.type),
              style: theme.textTheme.bodySmall?.copyWith(
                color: severityColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              timeAgo,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        trailing: alert.isRead
            ? null
            : Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: severityColor,
                  shape: BoxShape.circle,
                ),
              ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  static (Color, IconData) _severityDisplay(AlertSeverity severity) {
    return switch (severity) {
      AlertSeverity.info => (Colors.blue, Icons.info_outline),
      AlertSeverity.warning => (Colors.orange, Icons.warning_amber),
      AlertSeverity.critical => (Colors.red, Icons.error),
    };
  }

  static String _alertTypeLabel(AlertType type) {
    return switch (type) {
      AlertType.lowMoisture => 'Low Moisture',
      AlertType.highMoisture => 'High Moisture',
      AlertType.systemFailure => 'System Failure',
      AlertType.scheduleConflict => 'Schedule Conflict',
      AlertType.waterPressureLow => 'Low Pressure',
      AlertType.sensorOffline => 'Sensor Offline',
    };
  }

  static String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return DateFormat('MMM dd').format(timestamp);
  }
}
