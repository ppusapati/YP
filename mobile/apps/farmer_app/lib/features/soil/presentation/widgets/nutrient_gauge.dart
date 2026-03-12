import 'dart:math' as math;

import 'package:flutter/material.dart';

class NutrientGauge extends StatelessWidget {
  const NutrientGauge({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.maxValue,
    this.optimalMin,
    this.optimalMax,
    this.size = 100,
    this.color,
  });

  final String label;
  final double value;
  final String unit;
  final double maxValue;
  final double? optimalMin;
  final double? optimalMax;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final percentage = (value / maxValue).clamp(0.0, 1.0);
    final gaugeColor = color ?? _autoColor(percentage);

    return SizedBox(
      width: size,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _GaugePainter(
                percentage: percentage,
                color: gaugeColor,
                backgroundColor:
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                strokeWidth: size * 0.1,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      value.toStringAsFixed(1),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: size * 0.18,
                        color: gaugeColor,
                      ),
                    ),
                    Text(
                      unit,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: size * 0.1,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (optimalMin != null && optimalMax != null)
            Text(
              'Optimal: ${optimalMin!.toStringAsFixed(0)}-${optimalMax!.toStringAsFixed(0)}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 9,
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  static Color _autoColor(double percentage) {
    if (percentage < 0.25) return Colors.red;
    if (percentage < 0.5) return Colors.orange;
    if (percentage < 0.75) return Colors.green;
    return Colors.blue;
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({
    required this.percentage,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  final double percentage;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    const startAngle = -math.pi * 0.75;
    const sweepAngle = math.pi * 1.5;

    // Background arc
    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    // Value arc
    final valuePaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * percentage,
      false,
      valuePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.percentage != percentage || oldDelegate.color != color;
}
