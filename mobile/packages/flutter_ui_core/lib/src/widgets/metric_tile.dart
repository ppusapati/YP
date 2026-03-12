import 'package:flutter/material.dart';

import '../theme/app_typography.dart';

/// A compact tile displaying a metric label, value, and linear progress indicator.
///
/// The [progress] value should be between 0.0 and 1.0. The [color] is applied
/// to the progress bar and optionally to the value text.
class MetricTile extends StatelessWidget {
  const MetricTile({
    super.key,
    required this.label,
    required this.value,
    this.progress,
    this.color,
    this.subtitle,
    this.icon,
    this.onTap,
  });

  /// Descriptive label (e.g., "Soil Moisture").
  final String label;

  /// Formatted value string (e.g., "42 %").
  final String value;

  /// Optional linear progress, 0.0 – 1.0.
  final double? progress;

  /// Colour applied to the progress bar and value text.
  final Color? color;

  /// Optional secondary line beneath the value.
  final String? subtitle;

  /// Optional leading icon.
  final IconData? icon;

  /// Tap handler.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveColor = color ?? colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 22, color: effectiveColor),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          label,
                          style: AppTypography.bodySmall.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        value,
                        style: AppTypography.titleSmall.copyWith(
                          color: effectiveColor,
                        ),
                      ),
                    ],
                  ),
                  if (progress != null) ...[
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress!.clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor: effectiveColor.withValues(alpha: 0.12),
                        valueColor: AlwaysStoppedAnimation(effectiveColor),
                      ),
                    ),
                  ],
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: AppTypography.labelSmall.copyWith(
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
