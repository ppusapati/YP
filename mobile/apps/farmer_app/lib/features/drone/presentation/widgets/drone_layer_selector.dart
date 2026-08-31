import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/drone_layer_entity.dart';
import '../bloc/drone_bloc.dart';
import '../bloc/drone_event.dart';
import '../bloc/drone_state.dart';

class DroneLayerSelector extends StatelessWidget {
  const DroneLayerSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DroneBloc, DroneState>(
      builder: (context, state) {
        if (state is! DroneLayersLoaded) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: DroneLayerType.values.map((type) {
              final isActive = state.activeLayerTypes.contains(type);
              final hasLayer =
                  state.layers.any((l) => l.layerType == type);

              return FilterChip(
                label: Text(type.displayName),
                selected: isActive,
                onSelected: hasLayer
                    ? (selected) {
                        context.read<DroneBloc>().add(ToggleLayer(type));
                      }
                    : null,
                avatar: Icon(
                  _iconForType(type),
                  size: 18,
                  color: isActive
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                backgroundColor: hasLayer
                    ? null
                    : Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.5),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  IconData _iconForType(DroneLayerType type) {
    switch (type) {
      case DroneLayerType.orthomosaic:
        return Icons.satellite_alt;
      case DroneLayerType.ndvi:
        return Icons.grass;
      case DroneLayerType.plantDensity:
        return Icons.grid_on;
    }
  }
}
