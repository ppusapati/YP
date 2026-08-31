import 'package:flutter/material.dart';

/// A circular indicator showing a health score from 0-100.
class HealthScoreIndicator extends StatelessWidget {
  const HealthScoreIndicator({
    super.key,
    required this.score,
    this.size = 48,
  });

  final double score;
  final double size;

  Color _scoreColor(ColorScheme colorScheme) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    if (score >= 40) return Colors.deepOrange;
    return colorScheme.error;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = _scoreColor(colorScheme);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: score / 100,
            strokeWidth: 4,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          Text(
            '${score.toInt()}',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}
