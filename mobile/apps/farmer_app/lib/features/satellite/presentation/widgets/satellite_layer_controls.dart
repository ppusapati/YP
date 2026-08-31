import 'package:flutter/material.dart';

import '../../domain/entities/satellite_entity.dart';

/// Floating controls for toggling between satellite layer types.
class SatelliteLayerControls extends StatelessWidget {
  const SatelliteLayerControls({
    super.key,
    required this.selectedLayer,
    required this.onLayerChanged,
  });

  final SatelliteLayerType selectedLayer;
  final ValueChanged<SatelliteLayerType> onLayerChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: SatelliteLayerType.values.map((layer) {
            final isSelected = layer == selectedLayer;
            return InkWell(
              onTap: () => onLayerChanged(layer),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 52,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primaryContainer
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _iconForLayer(layer),
                      size: 20,
                      color: isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _shortLabel(layer),
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 9,
                        color: isSelected
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurfaceVariant,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  static IconData _iconForLayer(SatelliteLayerType layer) {
    return switch (layer) {
      SatelliteLayerType.rgb => Icons.image,
      SatelliteLayerType.ndvi => Icons.grass,
      SatelliteLayerType.ndwi => Icons.water_drop,
      SatelliteLayerType.evi => Icons.eco,
      SatelliteLayerType.falseColor => Icons.palette,
    };
  }

  static String _shortLabel(SatelliteLayerType layer) {
    return switch (layer) {
      SatelliteLayerType.rgb => 'RGB',
      SatelliteLayerType.ndvi => 'NDVI',
      SatelliteLayerType.ndwi => 'NDWI',
      SatelliteLayerType.evi => 'EVI',
      SatelliteLayerType.falseColor => 'FC',
    };
  }
}
