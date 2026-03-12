import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// A circular gauge widget for displaying a sensor reading within a min/max range.
///
/// The arc sweeps 240 degrees and is colour-graded according to [colors].
class SensorGauge extends StatelessWidget {
  const SensorGauge({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    this.unit = '',
    this.label,
    this.size = 140,
    this.strokeWidth = 12,
    this.colors,
    this.thresholdLow,
    this.thresholdHigh,
  });

  /// Current sensor value.
  final double value;

  /// Minimum of the gauge range.
  final double min;

  /// Maximum of the gauge range.
  final double max;

  /// Unit suffix (e.g., "% ", "C").
  final String unit;

  /// Optional label below the value.
  final String? label;

  /// Diameter of the gauge widget.
  final double size;

  /// Stroke width of the arc.
  final double strokeWidth;

  /// Gradient colours for the arc; defaults to a green-yellow-red ramp.
  final List<Color>? colors;

  /// Low threshold. Below this the reading is shown in warning colour.
  final double? thresholdLow;

  /// High threshold. Above this the reading is shown in warning colour.
  final double? thresholdHigh;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fraction = max > min ? ((value - min) / (max - min)).clamp(0.0, 1.0) : 0.0;

    final effectiveColors = colors ??
        const [AppColors.success, AppColors.warning, AppColors.error];

    Color valueColor;
    if (thresholdLow != null && value < thresholdLow!) {
      valueColor = AppColors.warning;
    } else if (thresholdHigh != null && value > thresholdHigh!) {
      valueColor = AppColors.error;
    } else {
      valueColor = colorScheme.primary;
    }

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GaugePainter(
          fraction: fraction,
          strokeWidth: strokeWidth,
          colors: effectiveColors,
          trackColor: colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1),
                    style: AppTypography.gaugeValue.copyWith(color: valueColor),
                  ),
                  if (unit.isNotEmpty)
                    Text(
                      ' $unit',
                      style: AppTypography.labelSmall.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
              if (label != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    label!,
                    style: AppTypography.labelSmall.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({
    required this.fraction,
    required this.strokeWidth,
    required this.colors,
    required this.trackColor,
  });

  final double fraction;
  final double strokeWidth;
  final List<Color> colors;
  final Color trackColor;

  static const double _startAngle = 150 * (math.pi / 180); // 7 o'clock
  static const double _sweepAngle = 240 * (math.pi / 180); // 240 deg arc

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, _startAngle, _sweepAngle, false, trackPaint);

    // Value arc
    if (fraction > 0) {
      final valueSweep = _sweepAngle * fraction;
      final gradient = SweepGradient(
        startAngle: _startAngle,
        endAngle: _startAngle + _sweepAngle,
        colors: colors,
      );

      final valuePaint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, _startAngle, valueSweep, false, valuePaint);
    }
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) =>
      fraction != oldDelegate.fraction ||
      strokeWidth != oldDelegate.strokeWidth ||
      trackColor != oldDelegate.trackColor;
}
