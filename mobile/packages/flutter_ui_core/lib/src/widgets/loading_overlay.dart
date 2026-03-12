import 'package:flutter/material.dart';

import '../theme/app_typography.dart';

/// A semi-transparent overlay that blocks interaction and shows a loading indicator.
///
/// Place this in a [Stack] over the content you want to block, or use the
/// static [LoadingOverlay.show] / [LoadingOverlay.hide] helpers for route-level
/// overlays.
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    super.key,
    this.isLoading = true,
    this.message,
    this.progress,
    this.child,
  });

  /// Whether the overlay is currently visible.
  final bool isLoading;

  /// Optional descriptive message displayed beneath the spinner.
  final String? message;

  /// If non-null, a determinate progress indicator is shown (0.0 – 1.0).
  final double? progress;

  /// The content beneath the overlay.
  final Widget? child;

  // ─── Imperative show/hide via OverlayEntry ─────────────────────────
  static OverlayEntry? _entry;

  static void show(
    BuildContext context, {
    String? message,
    double? progress,
  }) {
    hide();
    _entry = OverlayEntry(
      builder: (_) => LoadingOverlay(
        message: message,
        progress: progress,
      ),
    );
    Overlay.of(context).insert(_entry!);
  }

  static void hide() {
    _entry?.remove();
    _entry = null;
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoading && child != null) return child!;
    if (!isLoading) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        if (child != null) child!,
        Positioned.fill(
          child: ColoredBox(
            color: colorScheme.scrim.withValues(alpha: 0.45),
            child: Center(
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 28,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (progress != null)
                        SizedBox(
                          width: 56,
                          height: 56,
                          child: CircularProgressIndicator(
                            value: progress!.clamp(0.0, 1.0),
                            strokeWidth: 4,
                            color: colorScheme.primary,
                          ),
                        )
                      else
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: CircularProgressIndicator(
                            strokeWidth: 4,
                            color: colorScheme.primary,
                          ),
                        ),
                      if (message != null) ...[
                        const SizedBox(height: 18),
                        Text(
                          message!,
                          style: AppTypography.bodyMedium.copyWith(
                            color: colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      if (progress != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          '${(progress! * 100).round()} %',
                          style: AppTypography.labelMedium.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
