import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Displays an AI model confidence score as a colour-coded progress bar.
///
/// [confidence] ranges from 0.0 (no confidence) to 1.0 (full confidence).
class ConfidenceIndicator extends StatelessWidget {
  const ConfidenceIndicator({
    super.key,
    required this.confidence,
    this.label = 'Confidence',
    this.showPercentage = true,
    this.height = 8,
  });

  final double confidence;
  final String label;
  final bool showPercentage;
  final double height;

  Color _barColor() {
    final c = confidence.clamp(0.0, 1.0);
    if (c < 0.4) return AppColors.error;
    if (c < 0.7) return AppColors.warning;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final c = confidence.clamp(0.0, 1.0);
    final color = _barColor();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (showPercentage)
              Text(
                '${(c * 100).round()} %',
                style: AppTypography.labelSmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: LinearProgressIndicator(
            value: c,
            minHeight: height,
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}
