import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_core/src/engine/map_config.dart';
import 'package:flutter_map_core/src/engine/map_engine.dart';

import '../bloc/drone_bloc.dart';
import '../bloc/drone_event.dart';
import '../bloc/drone_state.dart';
import '../widgets/drone_layer_selector.dart';
import '../widgets/flight_date_picker.dart';

class DroneViewerScreen extends StatefulWidget {
  const DroneViewerScreen({
    super.key,
    this.fieldId,
  });

  final String? fieldId;

  @override
  State<DroneViewerScreen> createState() => _DroneViewerScreenState();
}

class _DroneViewerScreenState extends State<DroneViewerScreen> {
  late final MapEngine _mapEngine;
  bool _controlsExpanded = true;

  @override
  void initState() {
    super.initState();
    _mapEngine = MapEngine(
      config: const MapConfig(
        styleUrl: 'https://demotiles.maplibre.org/style.json',
        initialZoom: 16.0,
      ),
    );

    if (widget.fieldId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context
            .read<DroneBloc>()
            .add(LoadDroneLayers(fieldId: widget.fieldId!));
      });
    }
  }

  @override
  void dispose() {
    _mapEngine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drone Imagery'),
        actions: [
          IconButton(
            icon: Icon(
              _controlsExpanded
                  ? Icons.expand_less
                  : Icons.expand_more,
            ),
            onPressed: () {
              setState(() => _controlsExpanded = !_controlsExpanded);
            },
            tooltip: _controlsExpanded ? 'Hide controls' : 'Show controls',
          ),
        ],
      ),
      body: BlocBuilder<DroneBloc, DroneState>(
        builder: (context, state) {
          return Column(
            children: [
              if (_controlsExpanded) ...[
                const FlightDatePicker(),
                const SizedBox(height: 8),
                const DroneLayerSelector(),
                const Divider(height: 1),
              ],
              Expanded(
                child: Stack(
                  children: [
                    _mapEngine.buildMapWidget(
                      onMapReady: (controller) {
                        // Add tile overlays for visible layers when map is
                        // ready. In production, this uses MapLibre's
                        // addRasterSource + addRasterLayer APIs.
                      },
                    ),
                    if (state is DroneLoading)
                      const Center(child: CircularProgressIndicator()),
                    if (state is DroneError)
                      Center(
                        child: Card(
                          margin: const EdgeInsets.all(32),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color:
                                      Theme.of(context).colorScheme.error,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Failed to load drone data',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  state.message,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                FilledButton.tonal(
                                  onPressed: () {
                                    if (widget.fieldId != null) {
                                      context.read<DroneBloc>().add(
                                          LoadDroneLayers(
                                              fieldId: widget.fieldId!));
                                    }
                                  },
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    if (state is DroneLayersLoaded &&
                        state.visibleLayers.isNotEmpty)
                      Positioned(
                        bottom: 16,
                        left: 16,
                        child: _LayerLegend(state: state),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LayerLegend extends StatelessWidget {
  const _LayerLegend({required this.state});

  final DroneLayersLoaded state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Active Layers',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          ...state.visibleLayers.map((layer) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _colorForType(layer.layerType),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    layer.layerType.displayName,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Color _colorForType(dynamic type) {
    switch (type.toString()) {
      case 'DroneLayerType.orthomosaic':
        return const Color(0xFF2196F3);
      case 'DroneLayerType.ndvi':
        return const Color(0xFF4CAF50);
      case 'DroneLayerType.plantDensity':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF9E9E9E);
    }
  }
}
