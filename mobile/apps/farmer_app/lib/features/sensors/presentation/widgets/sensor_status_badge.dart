import 'package:flutter/material.dart';

import '../../domain/entities/sensor_entity.dart';

class SensorStatusBadge extends StatelessWidget {
  const SensorStatusBadge({
    super.key,
    required this.status,
    required this.batteryLevel,
    this.size = SensorBadgeSize.medium,
  });

  final SensorStatus status;
  final int batteryLevel;
  final SensorBadgeSize size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (label, color, icon) = _resolveStatusDisplay();

    final padding = switch (size) {
      SensorBadgeSize.small =>
        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      SensorBadgeSize.medium =>
        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      SensorBadgeSize.large =>
        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    };

    final fontSize = switch (size) {
      SensorBadgeSize.small => 10.0,
      SensorBadgeSize.medium => 12.0,
      SensorBadgeSize.large => 14.0,
    };

    final iconSize = switch (size) {
      SensorBadgeSize.small => 12.0,
      SensorBadgeSize.medium => 14.0,
      SensorBadgeSize.large => 16.0,
    };

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  (String, Color, IconData) _resolveStatusDisplay() {
    if (batteryLevel < 20 && status == SensorStatus.online) {
      return ('Low Battery', Colors.orange, Icons.battery_alert);
    }
    return switch (status) {
      SensorStatus.online => ('Online', Colors.green, Icons.circle),
      SensorStatus.offline => ('Offline', Colors.grey, Icons.circle_outlined),
      SensorStatus.lowBattery =>
        ('Low Battery', Colors.orange, Icons.battery_alert),
      SensorStatus.error => ('Error', Colors.red, Icons.error_outline),
    };
  }
}

enum SensorBadgeSize { small, medium, large }
