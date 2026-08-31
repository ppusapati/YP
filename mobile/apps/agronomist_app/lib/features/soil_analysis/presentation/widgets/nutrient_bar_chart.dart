import 'package:flutter/material.dart';

import '../../domain/entities/soil_analysis_entity.dart';

/// A horizontal bar chart showing NPK + organic matter levels.
class NutrientBarChart extends StatelessWidget {
  const NutrientBarChart({super.key, required this.analysis});

  final SoilAnalysisEntity analysis;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _NutrientBar(
          label: 'Nitrogen (N)',
          value: analysis.nitrogen,
          maxValue: 100,
          color: Colors.green,
          colorScheme: colorScheme,
        ),
        const SizedBox(height: 12),
        _NutrientBar(
          label: 'Phosphorus (P)',
          value: analysis.phosphorus,
          maxValue: 100,
          color: Colors.blue,
          colorScheme: colorScheme,
        ),
        const SizedBox(height: 12),
        _NutrientBar(
          label: 'Potassium (K)',
          value: analysis.potassium,
          maxValue: 100,
          color: Colors.orange,
          colorScheme: colorScheme,
        ),
        const SizedBox(height: 12),
        _NutrientBar(
          label: 'Organic Matter',
          value: analysis.organicMatter,
          maxValue: 10,
          color: Colors.brown,
          colorScheme: colorScheme,
        ),
      ],
    );
  }
}

class _NutrientBar extends StatelessWidget {
  const _NutrientBar({
    required this.label,
    required this.value,
    required this.maxValue,
    required this.color,
    required this.colorScheme,
  });

  final String label;
  final double value;
  final double maxValue;
  final Color color;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final fraction = (value / maxValue).clamp(0.0, 1.0);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.bodySmall),
            Text(value.toStringAsFixed(1),
                style: theme.textTheme.bodySmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 8,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
