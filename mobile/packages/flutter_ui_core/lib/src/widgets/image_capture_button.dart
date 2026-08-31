import 'package:flutter/material.dart';

import '../theme/app_typography.dart';

/// A prominent circular camera-capture button with an optional label.
///
/// Typically used for pest/disease photo capture flows.
class ImageCaptureButton extends StatelessWidget {
  const ImageCaptureButton({
    super.key,
    required this.onPressed,
    this.label,
    this.icon = Icons.camera_alt_rounded,
    this.size = 72,
    this.heroTag,
  });

  final VoidCallback? onPressed;
  final String? label;
  final IconData icon;
  final double size;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final button = Material(
      elevation: 4,
      shape: const CircleBorder(),
      color: colorScheme.primary,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: Icon(
              icon,
              size: size * 0.42,
              color: colorScheme.onPrimary,
            ),
          ),
        ),
      ),
    );

    if (label == null) {
      return heroTag != null ? Hero(tag: heroTag!, child: button) : button;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        heroTag != null ? Hero(tag: heroTag!, child: button) : button,
        const SizedBox(height: 8),
        Text(
          label!,
          style: AppTypography.labelMedium.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
