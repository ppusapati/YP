import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HarvestCountdown extends StatelessWidget {
  const HarvestCountdown({
    super.key,
    required this.harvestDate,
    required this.cropType,
    this.size = 140,
  });

  final DateTime harvestDate;
  final String cropType;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final now = DateTime.now();
    final daysRemaining = harvestDate.difference(now).inDays;
    final isPast = daysRemaining < 0;
    final isUrgent = daysRemaining >= 0 && daysRemaining <= 7;
    final isSoon = daysRemaining > 7 && daysRemaining <= 14;

    final color = isPast
        ? Colors.grey
        : isUrgent
            ? Colors.red
            : isSoon
                ? Colors.orange
                : Colors.green;

    // Progress based on a 120-day growing cycle
    final totalDays = 120;
    final progress = isPast
        ? 1.0
        : (1.0 - daysRemaining / totalDays).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.05),
            color.withValues(alpha: 0.12),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _CountdownRingPainter(
                progress: progress,
                color: color,
                backgroundColor:
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isPast ? 'READY' : '$daysRemaining',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: color,
                        fontSize: isPast ? size * 0.16 : size * 0.28,
                      ),
                    ),
                    if (!isPast)
                      Text(
                        'days',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: color.withValues(alpha: 0.8),
                          fontSize: size * 0.1,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cropType,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Harvest Date',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  DateFormat('MMMM dd, yyyy').format(harvestDate),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isPast
                        ? 'Ready for Harvest'
                        : isUrgent
                            ? 'Harvest This Week'
                            : isSoon
                                ? 'Harvest Soon'
                                : 'Growing',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CountdownRingPainter extends CustomPainter {
  _CountdownRingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  final double progress;
  final Color color;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 12) / 2;
    const startAngle = -math.pi / 2;
    const fullSweep = 2 * math.pi;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      fullSweep * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CountdownRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
