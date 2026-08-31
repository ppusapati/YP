import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ui_core/flutter_ui_core.dart';
import 'package:intl/intl.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../../domain/entities/observation_entity.dart';
import '../bloc/observation_bloc.dart';
import '../bloc/observation_event.dart';
import '../widgets/photo_gallery.dart';

/// Full detail view of a [FieldObservation] with photos, map, and notes.
class ObservationDetailScreen extends StatelessWidget {
  const ObservationDetailScreen({super.key, required this.observation});

  final FieldObservation observation;

  Color get _categoryColor => switch (observation.category) {
        ObservationCategory.pest => const Color(0xFFD32F2F),
        ObservationCategory.disease => const Color(0xFFE64A19),
        ObservationCategory.weed => const Color(0xFF7B1FA2),
        ObservationCategory.growth => const Color(0xFF388E3C),
        ObservationCategory.soil => const Color(0xFF795548),
        ObservationCategory.water => const Color(0xFF0288D1),
        ObservationCategory.weather => const Color(0xFF455A64),
        ObservationCategory.wildlife => const Color(0xFF689F38),
        ObservationCategory.equipment => const Color(0xFF616161),
        ObservationCategory.other => const Color(0xFF9E9E9E),
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy \'at\' h:mm a');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Observation'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _confirmDelete(context);
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Delete'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photos
            if (observation.photos.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: PhotoGallery(
                  photos: observation.photos,
                  height: 220,
                ),
              ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category and date
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _categoryColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          observation.category.label,
                          style: TextStyle(
                            color: _categoryColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        dateFormat.format(observation.timestamp),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Notes
                  Text('Notes', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      observation.notes.isNotEmpty
                          ? observation.notes
                          : 'No notes recorded.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.6,
                        color: observation.notes.isEmpty
                            ? theme.colorScheme.onSurfaceVariant
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Weather
                  if (observation.weather != null) ...[
                    Text('Weather Conditions',
                        style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          _WeatherStat(
                            icon: Icons.thermostat_outlined,
                            label: 'Temp',
                            value:
                                '${observation.weather!.temperature.toStringAsFixed(1)} C',
                          ),
                          const SizedBox(width: 24),
                          _WeatherStat(
                            icon: Icons.water_drop_outlined,
                            label: 'Humidity',
                            value:
                                '${observation.weather!.humidity.toStringAsFixed(0)}%',
                          ),
                          if (observation.weather!.windSpeed != null) ...[
                            const SizedBox(width: 24),
                            _WeatherStat(
                              icon: Icons.air_outlined,
                              label: 'Wind',
                              value:
                                  '${observation.weather!.windSpeed!.toStringAsFixed(1)} m/s',
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (observation.weather!.description != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        observation.weather!.description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                  ],

                  // Map
                  Text('Location', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  height: 200,
                  child: MapLibreMap(
                    styleString:
                        'https://api.maptiler.com/maps/basic-v2/style.json?key=placeholder',
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        observation.location.latitude,
                        observation.location.longitude,
                      ),
                      zoom: 15,
                    ),
                    onMapCreated: (controller) {
                      controller.addSymbol(SymbolOptions(
                        geometry: LatLng(
                          observation.location.latitude,
                          observation.location.longitude,
                        ),
                        iconImage: 'marker-15',
                        iconSize: 2.0,
                      ));
                    },
                    scrollGesturesEnabled: false,
                    zoomGesturesEnabled: false,
                    rotateGesturesEnabled: false,
                    tiltGesturesEnabled: false,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '${observation.location.latitude.toStringAsFixed(5)}, '
                '${observation.location.longitude.toStringAsFixed(5)}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Observation'),
        content: const Text(
          'Are you sure you want to delete this observation? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context
                  .read<ObservationBloc>()
                  .add(DeleteObservation(observation.id));
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _WeatherStat extends StatelessWidget {
  const _WeatherStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 22, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(value, style: theme.textTheme.titleSmall),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
