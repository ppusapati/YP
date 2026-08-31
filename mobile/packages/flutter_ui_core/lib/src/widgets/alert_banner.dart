import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Severity level for [AlertBanner].
enum AlertSeverity {
  info,
  warning,
  critical;

  Color get backgroundColor => switch (this) {
        AlertSeverity.info => AppColors.infoContainer,
        AlertSeverity.warning => AppColors.warningContainer,
        AlertSeverity.critical => AppColors.errorContainer,
      };

  Color get foregroundColor => switch (this) {
        AlertSeverity.info => AppColors.info,
        AlertSeverity.warning => const Color(0xFF7A5900),
        AlertSeverity.critical => AppColors.error,
      };

  IconData get defaultIcon => switch (this) {
        AlertSeverity.info => Icons.info_outline_rounded,
        AlertSeverity.warning => Icons.warning_amber_rounded,
        AlertSeverity.critical => Icons.error_outline_rounded,
      };
}

/// A horizontal alert banner with severity-based styling, dismiss, and action.
class AlertBanner extends StatelessWidget {
  const AlertBanner({
    super.key,
    required this.message,
    this.severity = AlertSeverity.info,
    this.title,
    this.icon,
    this.onDismiss,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final AlertSeverity severity;
  final String? title;
  final IconData? icon;

  /// If non-null a close button is shown.
  final VoidCallback? onDismiss;

  /// Optional trailing action button label.
  final String? actionLabel;

  /// Callback for the action button.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final bg = severity.backgroundColor;
    final fg = severity.foregroundColor;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon ?? severity.defaultIcon, color: fg, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        title!,
                        style: AppTypography.titleSmall.copyWith(color: fg),
                      ),
                    ),
                  Text(
                    message,
                    style: AppTypography.bodySmall.copyWith(color: fg),
                  ),
                  if (actionLabel != null && onAction != null) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 32,
                      child: TextButton(
                        onPressed: onAction,
                        style: TextButton.styleFrom(
                          foregroundColor: fg,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          textStyle: AppTypography.labelMedium,
                        ),
                        child: Text(actionLabel!),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (onDismiss != null)
              SizedBox(
                width: 28,
                height: 28,
                child: IconButton(
                  onPressed: onDismiss,
                  icon: Icon(Icons.close_rounded, size: 18, color: fg),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
