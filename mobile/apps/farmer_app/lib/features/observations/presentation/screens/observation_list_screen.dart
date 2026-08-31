import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../../domain/entities/observation_entity.dart';
import '../bloc/observation_bloc.dart';
import '../bloc/observation_event.dart';
import '../bloc/observation_state.dart';
import '../widgets/observation_card.dart';
import 'observation_detail_screen.dart';
import 'observation_editor_screen.dart';

/// Displays a list of observations with an optional map markers view.
class ObservationListScreen extends StatefulWidget {
  const ObservationListScreen({super.key, this.fieldId});

  final String? fieldId;

  @override
  State<ObservationListScreen> createState() => _ObservationListScreenState();
}

class _ObservationListScreenState extends State<ObservationListScreen> {
  bool _showMap = false;

  @override
  void initState() {
    super.initState();
    context
        .read<ObservationBloc>()
        .add(LoadObservations(fieldId: widget.fieldId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Observations'),
        actions: [
          IconButton(
            icon: Icon(_showMap ? Icons.list : Icons.map_outlined),
            onPressed: () => setState(() => _showMap = !_showMap),
            tooltip: _showMap ? 'List view' : 'Map view',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context
                  .read<ObservationBloc>()
                  .add(LoadObservations(fieldId: widget.fieldId));
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: BlocConsumer<ObservationBloc, ObservationState>(
        listener: (context, state) {
          if (state is ObservationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          if (state is ObservationCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Observation saved'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ObservationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ObservationsLoaded) {
            if (state.observations.isEmpty) {
              return _buildEmpty(theme);
            }
            return _showMap
                ? _buildMapView(context, state.observations)
                : _buildListView(context, state.observations);
          }

          return _buildEmpty(theme);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToEditor(context),
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text('New Observation'),
      ),
    );
  }

  Widget _buildEmpty(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.nature_outlined, size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text('No observations yet', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Start recording what you see in the field',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(
    BuildContext context,
    List<FieldObservation> observations,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        context
            .read<ObservationBloc>()
            .add(LoadObservations(fieldId: widget.fieldId));
      },
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: observations.length,
        separatorBuilder: (_, __) => const SizedBox(height: 6),
        itemBuilder: (context, index) {
          final obs = observations[index];
          return ObservationCard(
            observation: obs,
            onTap: () => _navigateToDetail(context, obs),
          );
        },
      ),
    );
  }

  Widget _buildMapView(
    BuildContext context,
    List<FieldObservation> observations,
  ) {
    return MapLibreMap(
      styleString:
          'https://api.maptiler.com/maps/basic-v2/style.json?key=placeholder',
      initialCameraPosition: CameraPosition(
        target: observations.isNotEmpty
            ? LatLng(
                observations.first.location.latitude,
                observations.first.location.longitude,
              )
            : const LatLng(-1.286389, 36.817223),
        zoom: 12,
      ),
      onMapCreated: (controller) {
        for (final obs in observations) {
          controller.addSymbol(SymbolOptions(
            geometry: LatLng(
              obs.location.latitude,
              obs.location.longitude,
            ),
            iconImage: 'marker-15',
            iconSize: 1.5,
          ));
        }
      },
      onSymbolTapped: (symbol) {
        // Find observation near tapped symbol
        final geo = symbol.options.geometry;
        if (geo == null) return;
        for (final obs in observations) {
          if ((obs.location.latitude - geo.latitude).abs() < 0.0001 &&
              (obs.location.longitude - geo.longitude).abs() < 0.0001) {
            _navigateToDetail(context, obs);
            break;
          }
        }
      },
    );
  }

  void _navigateToDetail(BuildContext context, FieldObservation observation) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: context.read<ObservationBloc>(),
          child: ObservationDetailScreen(observation: observation),
        ),
      ),
    );
  }

  void _navigateToEditor(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: context.read<ObservationBloc>(),
          child: ObservationEditorScreen(fieldId: widget.fieldId ?? ''),
        ),
      ),
    );
  }
}
