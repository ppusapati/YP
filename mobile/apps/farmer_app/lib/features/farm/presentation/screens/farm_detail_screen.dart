import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maplibre_gl/maplibre_gl.dart' as ml;

import '../../domain/entities/farm_entity.dart';
import '../../domain/entities/field_entity.dart';
import '../bloc/farm_bloc.dart';
import '../bloc/farm_event.dart';
import '../bloc/farm_state.dart';
import '../bloc/field_bloc.dart';
import '../bloc/field_event.dart';
import '../bloc/field_state.dart';
import '../widgets/farm_stats_row.dart';
import '../widgets/field_list_tile.dart';
import 'farm_editor_screen.dart';
import 'field_editor_screen.dart';

/// Screen showing farm details with a map view, statistics, and fields list.
class FarmDetailScreen extends StatefulWidget {
  const FarmDetailScreen({super.key, required this.farmId});

  final String farmId;

  static const String routePath = '/farm/:id';

  @override
  State<FarmDetailScreen> createState() => _FarmDetailScreenState();
}

class _FarmDetailScreenState extends State<FarmDetailScreen> {
  ml.MaplibreMapController? _mapController;

  @override
  void initState() {
    super.initState();
    context.read<FarmBloc>().add(LoadFarmById(farmId: widget.farmId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<FarmBloc, FarmState>(
      builder: (context, state) {
        if (state is FarmLoading) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (state is FarmError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline,
                      size: 48, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      context
                          .read<FarmBloc>()
                          .add(LoadFarmById(farmId: widget.farmId));
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        if (state is FarmLoaded) {
          return _buildContent(context, state.farm);
        }
        return Scaffold(appBar: AppBar());
      },
    );
  }

  Widget _buildContent(BuildContext context, FarmEntity farm) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(farm.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _navigateToEditor(context, farm),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteDialog(context, farm);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete Farm'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: 220,
              child: _FarmMapPreview(
                farm: farm,
                onMapCreated: (controller) {
                  _mapController = controller;
                },
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: FarmStatsRow(farm: farm),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Fields',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _navigateToFieldEditor(context, farm.id),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Field'),
                  ),
                ],
              ),
            ),
          ),
          if (farm.fields.isEmpty)
            SliverPadding(
              padding: const EdgeInsets.all(32),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.grid_view,
                        size: 48,
                        color: colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No fields yet',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add fields to track crops and manage this farm',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList.builder(
                itemCount: farm.fields.length,
                itemBuilder: (context, index) {
                  final field = farm.fields[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: FieldListTile(
                      field: field,
                      onTap: () => _navigateToFieldEditor(
                        context,
                        farm.id,
                        existingField: field,
                      ),
                      onDelete: () =>
                          _showDeleteFieldDialog(context, field, farm.id),
                    ),
                  );
                },
              ),
            ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
        ],
      ),
    );
  }

  void _navigateToEditor(BuildContext context, FarmEntity farm) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: context.read<FarmBloc>(),
          child: FarmEditorScreen(existingFarm: farm),
        ),
      ),
    );
  }

  void _navigateToFieldEditor(
    BuildContext context,
    String farmId, {
    FieldEntity? existingField,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: context.read<FarmBloc>(),
          child: FieldEditorScreen(
            farmId: farmId,
            existingField: existingField,
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, FarmEntity farm) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Farm'),
        content: Text(
            'Are you sure you want to delete "${farm.name}"? '
            'This action cannot be undone and will remove all associated fields.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<FarmBloc>().add(DeleteFarm(farmId: farm.id));
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showDeleteFieldDialog(
      BuildContext context, FieldEntity field, String farmId) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Field'),
        content: Text('Delete "${field.name}" from this farm?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<FarmBloc>().add(LoadFarmById(farmId: farmId));
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _FarmMapPreview extends StatelessWidget {
  const _FarmMapPreview({required this.farm, required this.onMapCreated});

  final FarmEntity farm;
  final void Function(ml.MaplibreMapController) onMapCreated;

  @override
  Widget build(BuildContext context) {
    if (farm.boundaries.isEmpty) {
      final colorScheme = Theme.of(context).colorScheme;
      return Container(
        color: colorScheme.surfaceContainerLow,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.map_outlined,
                  size: 48,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
              const SizedBox(height: 8),
              Text(
                'No boundary defined',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    // Calculate center from boundaries.
    final latSum =
        farm.boundaries.fold(0.0, (sum, b) => sum + b.latitude);
    final lngSum =
        farm.boundaries.fold(0.0, (sum, b) => sum + b.longitude);
    final center = ml.LatLng(
      latSum / farm.boundaries.length,
      lngSum / farm.boundaries.length,
    );

    return ml.MaplibreMap(
      styleString:
          'https://demotiles.maplibre.org/style.json',
      initialCameraPosition: ml.CameraPosition(
        target: center,
        zoom: 14.0,
      ),
      onMapCreated: onMapCreated,
      rotateGesturesEnabled: false,
      tiltGesturesEnabled: false,
      myLocationEnabled: false,
      compassEnabled: false,
    );
  }
}
