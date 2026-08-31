import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ui_core/flutter_ui_core.dart';
import 'package:intl/intl.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../../domain/entities/produce_record_entity.dart';
import '../bloc/traceability_bloc.dart';
import '../bloc/traceability_event.dart';
import '../widgets/certification_badge.dart';
import '../widgets/treatment_timeline.dart';
import 'farm_history_screen.dart';

/// Detailed view of a [ProduceRecord] showing origin, treatments, and certifications.
class ProduceDetailScreen extends StatelessWidget {
  const ProduceDetailScreen({super.key, required this.record});

  final ProduceRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMMM d, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Produce Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_outlined),
            onPressed: () {
              context
                  .read<TraceabilityBloc>()
                  .add(LoadFarmHistory(record.farmId));
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => BlocProvider.value(
                    value: context.read<TraceabilityBloc>(),
                    child: FarmHistoryScreen(farmName: record.farmName),
                  ),
                ),
              );
            },
            tooltip: 'Farm history',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product header card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.1),
                    AppColors.primary.withValues(alpha: 0.03),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.eco,
                            size: 28, color: AppColors.primary),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              record.cropVariety,
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Batch: ${record.batchId}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  _InfoRow(
                    icon: Icons.agriculture_outlined,
                    label: 'Farm',
                    value: record.farmName,
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Harvested',
                    value: dateFormat.format(record.harvestDate),
                  ),
                  if (record.packingDate != null) ...[
                    const SizedBox(height: 8),
                    _InfoRow(
                      icon: Icons.inventory_2_outlined,
                      label: 'Packed',
                      value: dateFormat.format(record.packingDate!),
                    ),
                  ],
                  if (record.expiryDate != null) ...[
                    const SizedBox(height: 8),
                    _InfoRow(
                      icon: Icons.event_busy_outlined,
                      label: 'Best Before',
                      value: dateFormat.format(record.expiryDate!),
                      valueColor: record.expiryDate!.isBefore(DateTime.now())
                          ? AppColors.error
                          : null,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Farm location
            Text('Farm Location', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 160,
                child: MapLibreMap(
                  styleString:
                      'https://api.maptiler.com/maps/basic-v2/style.json?key=placeholder',
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      record.farmLocation.latitude,
                      record.farmLocation.longitude,
                    ),
                    zoom: 13,
                  ),
                  onMapCreated: (controller) {
                    controller.addSymbol(SymbolOptions(
                      geometry: LatLng(
                        record.farmLocation.latitude,
                        record.farmLocation.longitude,
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

            const SizedBox(height: 24),

            // Certifications
            if (record.certifications.isNotEmpty) ...[
              Text('Certifications', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              ...record.certifications.map((cert) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: CertificationBadge(certification: cert),
                  )),
              const SizedBox(height: 16),
            ],

            // Treatment history
            Text('Treatment History', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              '${record.treatments.length} treatment${record.treatments.length == 1 ? '' : 's'} applied',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            TreatmentTimeline(treatments: record.treatments),

            // Notes
            if (record.notes != null && record.notes!.isNotEmpty) ...[
              const SizedBox(height: 24),
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
                  record.notes!,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                ),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }
}
