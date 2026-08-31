import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Circular gauge widget showing a 0-100% risk score with color gradient.
///
/// Green (low risk) -> Yellow (moderate) -> Orange (high) -> Red (critical).
class RiskGauge extends StatelessWidget {
  const RiskGauge({
    super.key,
    required this.score,
    this.size = 120,
    this.strokeWidth = 10,
    this.label,
  });

  /// Risk score from 0 to 100.
  final double score;

  /// Overall size of the gauge widget.
  final double size;

  /// Width of the arc stroke.
  final double strokeWidth;

  /// Optional label displayed below the score.
  final String? label;

  Color _scoreColor() {
    if (score >= 80) return const Color(0xFFD32F2F);
    if (score >= 60) return const Color(0xFFE65100);
    if (score >= 40) return const Color(0xFFF9A825);
    if (score >= 20) return const Color(0xFF66BB6A);
    return const Color(0xFF2E7D32);
  }

  String _riskLabel() {
    if (score >= 80) return 'Critical';
    if (score >= 60) return 'High';
    if (score >= 40) return 'Moderate';
    if (score >= 20) return 'Low';
    return 'Minimal';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _scoreColor();

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RiskGaugePainter(
              score: score.clamp(0, 100),
              color: color,
              trackColor: theme.colorScheme.surfaceContainerHighest,
              strokeWidth: strokeWidth,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${score.toInt()}%',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              Text(
                label ?? _riskLabel(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RiskGaugePainter extends CustomPainter {
  _RiskGaugePainter({
    required this.score,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  final double score;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Start from the bottom-left (225 degrees) and sweep 270 degrees.
    const startAngle = 135 * math.pi / 180;
    const sweepTotal = 270 * math.pi / 180;
    final sweepAngle = sweepTotal * (score / 100);

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final scorePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw track.
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepTotal,
      false,
      trackPaint,
    );

    // Draw score arc.
    if (score > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        scorePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RiskGaugePainter oldDelegate) {
    return oldDelegate.score != score || oldDelegate.color != color;
  }
}
