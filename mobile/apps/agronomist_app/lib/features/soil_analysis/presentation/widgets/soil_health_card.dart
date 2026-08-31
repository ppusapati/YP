import 'package:flutter/material.dart';

import '../../domain/entities/soil_analysis_entity.dart';

/// A summary card showing soil health score and pH.
class SoilHealthCard extends StatelessWidget {
  const SoilHealthCard({super.key, required this.analysis, this.onTap});

  final SoilAnalysisEntity analysis;
  final VoidCallback? onTap;

  Color _healthColor(ColorScheme colorScheme) {
    if (analysis.healthScore >= 80) return Colors.green;
    if (analysis.healthScore >= 60) return Colors.orange;
    if (analysis.healthScore >= 40) return Colors.deepOrange;
    return colorScheme.error;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final healthColor = _healthColor(colorScheme);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              SizedBox(
                width: 56,
                height: 56,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: analysis.healthScore / 100,
                      strokeWidth: 5,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(healthColor),
                    ),
                    Text(
                      '${analysis.healthScore.toInt()}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: healthColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Soil Health: ${analysis.healthLabel}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'pH ${analysis.pH.toStringAsFixed(1)} | NPK ${analysis.nitrogen.toStringAsFixed(0)}-${analysis.phosphorus.toStringAsFixed(0)}-${analysis.potassium.toStringAsFixed(0)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
