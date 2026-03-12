import 'package:flutter/material.dart';

class PhIndicator extends StatelessWidget {
  const PhIndicator({
    super.key,
    required this.pH,
    this.height = 24,
    this.showLabels = true,
  });

  final double pH;
  final double height;
  final bool showLabels;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final normalizedPosition = ((pH - 0) / 14).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabels)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'pH: ${pH.toStringAsFixed(1)}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _phColor(pH).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _phClassification(pH),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: _phColor(pH),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                // Gradient bar
                Container(
                  height: height,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(height / 2),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFF0000), // pH 0-2: red
                        Color(0xFFFF6600), // pH 3-4: orange
                        Color(0xFFFFCC00), // pH 5: yellow
                        Color(0xFF66CC00), // pH 6: yellow-green
                        Color(0xFF00CC00), // pH 7: green
                        Color(0xFF009966), // pH 8: teal
                        Color(0xFF0066CC), // pH 9-10: blue
                        Color(0xFF3300CC), // pH 11-12: indigo
                        Color(0xFF660099), // pH 13-14: purple
                      ],
                    ),
                  ),
                ),
                // Indicator
                Positioned(
                  left: (width * normalizedPosition - 8).clamp(0, width - 16),
                  top: -4,
                  child: Container(
                    width: 16,
                    height: height + 8,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: colorScheme.onSurface,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        if (showLabels)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Acidic',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  'Neutral',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  'Alkaline',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  static Color _phColor(double pH) {
    if (pH < 4) return Colors.red;
    if (pH < 5.5) return Colors.orange;
    if (pH < 6.5) return Colors.yellow.shade800;
    if (pH < 7.5) return Colors.green;
    if (pH < 8.5) return Colors.teal;
    if (pH < 10) return Colors.blue;
    return Colors.purple;
  }

  static String _phClassification(double pH) {
    if (pH < 4.5) return 'Very Acidic';
    if (pH < 5.5) return 'Acidic';
    if (pH < 6.5) return 'Slightly Acidic';
    if (pH < 7.5) return 'Neutral';
    if (pH < 8.5) return 'Slightly Alkaline';
    if (pH < 9.5) return 'Alkaline';
    return 'Very Alkaline';
  }
}
