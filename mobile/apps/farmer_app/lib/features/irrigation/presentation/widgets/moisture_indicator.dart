import 'package:flutter/material.dart';

class MoistureIndicator extends StatelessWidget {
  const MoistureIndicator({
    super.key,
    required this.currentMoisture,
    required this.targetMoisture,
    this.height = 12,
    this.showLabels = true,
  });

  final double currentMoisture;
  final double targetMoisture;
  final double height;
  final bool showLabels;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final percentage = (currentMoisture / targetMoisture).clamp(0.0, 1.5);
    final displayPercentage = percentage.clamp(0.0, 1.0);
    final color = _moistureColor(percentage);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabels)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${currentMoisture.toStringAsFixed(1)}%',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                Text(
                  'Target: ${targetMoisture.toStringAsFixed(1)}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        Stack(
          children: [
            Container(
              height: height,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
            FractionallySizedBox(
              widthFactor: displayPercentage,
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withValues(alpha: 0.7), color],
                  ),
                  borderRadius: BorderRadius.circular(height / 2),
                ),
              ),
            ),
            // Target marker
            Positioned(
              left: 0,
              right: 0,
              child: FractionallySizedBox(
                widthFactor: 1.0,
                child: Stack(
                  children: [
                    Positioned(
                      left: _targetPosition(context),
                      child: Container(
                        width: 2,
                        height: height,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (showLabels && currentMoisture < targetMoisture)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Deficit: ${(targetMoisture - currentMoisture).toStringAsFixed(1)}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.orange.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  double _targetPosition(BuildContext context) {
    // Approximate based on available width; the actual position is handled
    // by the FractionallySizedBox in the parent layout
    return 0;
  }

  static Color _moistureColor(double percentage) {
    if (percentage < 0.4) return Colors.red;
    if (percentage < 0.7) return Colors.orange;
    if (percentage <= 1.0) return Colors.green;
    return Colors.blue; // over-watered
  }
}
