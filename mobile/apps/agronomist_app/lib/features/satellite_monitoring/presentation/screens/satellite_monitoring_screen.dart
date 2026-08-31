import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/satellite_bloc.dart';
import '../bloc/satellite_event.dart';
import '../bloc/satellite_state.dart';

/// Screen for viewing satellite monitoring data for a field.
class SatelliteMonitoringScreen extends StatefulWidget {
  const SatelliteMonitoringScreen({super.key, required this.fieldId});

  final String fieldId;

  @override
  State<SatelliteMonitoringScreen> createState() =>
      _SatelliteMonitoringScreenState();
}

class _SatelliteMonitoringScreenState extends State<SatelliteMonitoringScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<SatelliteBloc>()
        .add(LoadSatelliteTiles(fieldId: widget.fieldId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Satellite Monitoring')),
      body: BlocBuilder<SatelliteBloc, SatelliteState>(
        builder: (context, state) {
          if (state is SatelliteLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SatelliteError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline,
                      size: 48, color: theme.colorScheme.error),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => context.read<SatelliteBloc>().add(
                        LoadSatelliteTiles(fieldId: widget.fieldId)),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is SatelliteTilesLoaded) {
            if (state.tiles.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.satellite_alt,
                        size: 80,
                        color: theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.4)),
                    const SizedBox(height: 24),
                    Text('No satellite data',
                        style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text(
                      'Satellite imagery will appear\nonce available for this field.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.tiles.length,
              itemBuilder: (context, index) {
                final tile = state.tiles[index];
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                        color: theme.colorScheme.outlineVariant),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.satellite_alt,
                        color: theme.colorScheme.primary),
                    title: Text(tile.indexType.displayName),
                    subtitle: Text(
                        '${tile.captureDate.year}-${tile.captureDate.month.toString().padLeft(2, '0')}-${tile.captureDate.day.toString().padLeft(2, '0')}'),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
