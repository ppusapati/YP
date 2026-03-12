import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_core/src/engine/map_config.dart';
import 'package:flutter_map_core/src/engine/map_engine.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../../domain/entities/crop_issue_entity.dart';
import '../bloc/gps_tracking_bloc.dart';
import '../bloc/gps_tracking_event.dart';
import '../bloc/gps_tracking_state.dart';
import '../widgets/issue_marker_dialog.dart';
import '../widgets/tracking_controls.dart';
import '../widgets/tracking_stats.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({
    super.key,
    required this.fieldId,
  });

  final String fieldId;

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  late final MapEngine _mapEngine;
  MapLibreMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _mapEngine = MapEngine(
      config: const MapConfig(
        styleUrl: 'https://demotiles.maplibre.org/style.json',
        initialZoom: 16.0,
        myLocationEnabled: true,
      ),
    );
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
        title: const Text('Field Tracking'),
      ),
      body: BlocConsumer<GPSTrackingBloc, GPSTrackingState>(
        listener: (context, state) {
          if (state is TrackingStopped) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Track saved. Distance: '
                  '${(state.summary.distance / 1000).toStringAsFixed(2)} km',
                ),
              ),
            );
          }
          if (state is TrackingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
          if (state is TrackingActive) {
            _updateTrackLine(state);
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              _mapEngine.buildMapWidget(
                onMapReady: (controller) {
                  _mapController = controller.controller;
                },
              ),
              if (state is TrackingActive || state is TrackingPaused)
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: TrackingStats(),
                ),
              if (state is TrackingPaused)
                Positioned(
                  top: 120,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .tertiaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.pause_circle_filled,
                            size: 18,
                            color: Theme.of(context)
                                .colorScheme
                                .onTertiaryContainer,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Tracking Paused',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onTertiaryContainer,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: TrackingControls(
                  fieldId: widget.fieldId,
                  onIssuePressed: () => _showIssueDialog(context),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showIssueDialog(BuildContext context) async {
    final state = context.read<GPSTrackingBloc>().state;
    if (state is! TrackingActive) return;

    final result = await IssueMarkerDialog.show(
      context,
      location: state.currentPosition,
    );

    if (result != null && mounted) {
      context.read<GPSTrackingBloc>().add(MarkIssue(
            location: state.currentPosition,
            type: result.type,
            description: result.description,
            severity: result.severity,
            photos: result.photos,
          ));
    }
  }

  void _updateTrackLine(TrackingActive state) {
    if (_mapController == null || state.track.path.length < 2) return;

    // In a real implementation, this would update a GeoJSON source for
    // the line layer. MapLibre does not have a native polyline API like
    // Google Maps, so we rely on GeoJSON sources.
  }
}
