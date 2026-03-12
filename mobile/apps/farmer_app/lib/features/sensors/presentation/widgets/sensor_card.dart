import 'package:flutter/material.dart';

import '../../domain/entities/sensor_entity.dart';
import 'sensor_status_badge.dart';

class SensorCard extends StatelessWidget {
  const SensorCard({
    super.key,
    required this.sensor,
    this.onTap,
  });

  final Sensor sensor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                  _SensorTypeIcon(type: sensor.type),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sensor.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _sensorTypeLabel(sensor.type),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SensorStatusBadge(
                    status: sensor.status,
                    batteryLevel: sensor.batteryLevel,
                    size: SensorBadgeSize.small,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _ReadingGauge(
                value: sensor.lastReading,
                type: sensor.type,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _BatteryIndicator(level: sensor.batteryLevel),
                  if (sensor.location.fieldName != null)
                    Flexible(
                      child: Text(
                        sensor.location.fieldName!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

  static String _sensorTypeLabel(SensorType type) {
    return switch (type) {
      SensorType.temperature => 'Temperature',
      SensorType.humidity => 'Humidity',
      SensorType.soilMoisture => 'Soil Moisture',
      SensorType.light => 'Light',
      SensorType.windSpeed => 'Wind Speed',
      SensorType.rainfall => 'Rainfall',
      SensorType.pressure => 'Pressure',
    };
  }
}

class _SensorTypeIcon extends StatelessWidget {
  const _SensorTypeIcon({required this.type});

  final SensorType type;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final (icon, color) = _iconForType(type, colorScheme);

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }

  static (IconData, Color) _iconForType(
    SensorType type,
    ColorScheme scheme,
  ) {
    return switch (type) {
      SensorType.temperature => (Icons.thermostat, Colors.deepOrange),
      SensorType.humidity => (Icons.water_drop, Colors.blue),
      SensorType.soilMoisture => (Icons.grass, Colors.brown),
      SensorType.light => (Icons.wb_sunny, Colors.amber),
      SensorType.windSpeed => (Icons.air, Colors.teal),
      SensorType.rainfall => (Icons.grain, Colors.indigo),
      SensorType.pressure => (Icons.speed, Colors.purple),
    };
  }
}

class _ReadingGauge extends StatelessWidget {
  const _ReadingGauge({required this.value, required this.type});

  final double value;
  final SensorType type;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final (unit, max) = _unitAndMax(type);
    final percentage = (value / max).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value.toStringAsFixed(1),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              unit,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 6,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              _gaugeColor(percentage),
            ),
          ),
        ),
      ],
    );
  }

  static (String, double) _unitAndMax(SensorType type) {
    return switch (type) {
      SensorType.temperature => ('\u00B0C', 50),
      SensorType.humidity => ('%', 100),
      SensorType.soilMoisture => ('%', 100),
      SensorType.light => ('lux', 100000),
      SensorType.windSpeed => ('m/s', 50),
      SensorType.rainfall => ('mm', 200),
      SensorType.pressure => ('hPa', 1100),
    };
  }

  static Color _gaugeColor(double percentage) {
    if (percentage < 0.3) return Colors.green;
    if (percentage < 0.7) return Colors.orange;
    return Colors.red;
  }
}

class _BatteryIndicator extends StatelessWidget {
  const _BatteryIndicator({required this.level});

  final int level;

  @override
  Widget build(BuildContext context) {
    final color = level > 50
        ? Colors.green
        : level > 20
            ? Colors.orange
            : Colors.red;
    final icon = level > 80
        ? Icons.battery_full
        : level > 50
            ? Icons.battery_5_bar
            : level > 20
                ? Icons.battery_3_bar
                : Icons.battery_alert;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          '$level%',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
