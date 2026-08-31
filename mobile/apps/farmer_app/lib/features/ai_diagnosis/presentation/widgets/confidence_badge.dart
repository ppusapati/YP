import 'package:flutter/material.dart';

/// Size variants for the confidence badge.
enum ConfidenceBadgeSize { small, regular }

/// A badge displaying the AI confidence percentage with color coding.
class ConfidenceBadge extends StatelessWidget {
  const ConfidenceBadge({
    super.key,
    required this.confidence,
    this.size = ConfidenceBadgeSize.regular,
  });

  /// Confidence value between 0.0 and 1.0.
  final double confidence;
  final ConfidenceBadgeSize size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = (confidence * 100).toStringAsFixed(0);
    final color = _confidenceColor(confidence);
    final isSmall = size == ConfidenceBadgeSize.small;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 6 : 10,
        vertical: isSmall ? 3 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(isSmall ? 6 : 8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isSmall) ...[
            Icon(
              _confidenceIcon(confidence),
              size: 16,
              color: color,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            '$percent%',
            style: (isSmall
                    ? theme.textTheme.labelSmall
                    : theme.textTheme.labelLarge)
                ?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  static Color _confidenceColor(double confidence) {
    if (confidence >= 0.9) return Colors.green.shade700;
    if (confidence >= 0.7) return Colors.green;
    if (confidence >= 0.5) return Colors.orange;
    return Colors.red;
  }

  static IconData _confidenceIcon(double confidence) {
    if (confidence >= 0.9) return Icons.verified;
    if (confidence >= 0.7) return Icons.check_circle;
    if (confidence >= 0.5) return Icons.help;
    return Icons.warning;
  }
}
