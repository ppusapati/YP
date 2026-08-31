import 'package:flutter/material.dart';

import '../../domain/entities/soil_analysis_entity.dart';

class SoilSummaryCard extends StatelessWidget {
  const SoilSummaryCard({
    super.key,
    required this.analysis,
    this.onTap,
  });

  final SoilAnalysis analysis;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ratingColor = _ratingColor(analysis.fertilityRating);

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.brown.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.landscape,
                        color: Colors.brown, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Soil Health',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (analysis.fieldName != null)
                          Text(
                            analysis.fieldName!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: ratingColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      analysis.fertilityRating,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: ratingColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _NutrientChip(
                    label: 'pH',
                    value: analysis.pH.toStringAsFixed(1),
                    color: _phColor(analysis.pH),
                  ),
                  _NutrientChip(
                    label: 'N',
                    value: '${analysis.nitrogen.toStringAsFixed(0)} kg/ha',
                    color: Colors.green,
                  ),
                  _NutrientChip(
                    label: 'P',
                    value: '${analysis.phosphorus.toStringAsFixed(0)} kg/ha',
                    color: Colors.orange,
                  ),
                  _NutrientChip(
                    label: 'K',
                    value: '${analysis.potassium.toStringAsFixed(0)} kg/ha',
                    color: Colors.purple,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.texture,
                      size: 14, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    'Texture: ${_textureLabel(analysis.texture)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'OC: ${analysis.organicCarbon.toStringAsFixed(2)}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Color _ratingColor(String rating) {
    return switch (rating) {
      'Excellent' => Colors.green.shade700,
      'Good' => Colors.green,
      'Moderate' => Colors.orange,
      'Low' => Colors.red.shade400,
      _ => Colors.red,
    };
  }

  static Color _phColor(double pH) {
    if (pH < 5.5) return Colors.red;
    if (pH < 6.5) return Colors.orange;
    if (pH < 7.5) return Colors.green;
    if (pH < 8.5) return Colors.blue;
    return Colors.purple;
  }

  static String _textureLabel(SoilTexture texture) {
    return switch (texture) {
      SoilTexture.sandy => 'Sandy',
      SoilTexture.loamy => 'Loamy',
      SoilTexture.clay => 'Clay',
      SoilTexture.silt => 'Silt',
      SoilTexture.sandyLoam => 'Sandy Loam',
      SoilTexture.clayLoam => 'Clay Loam',
      SoilTexture.siltLoam => 'Silt Loam',
    };
  }
}

class _NutrientChip extends StatelessWidget {
  const _NutrientChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
