import 'package:flutter/material.dart';
import 'package:flutter_map_core/src/engine/map_config.dart';
import 'package:flutter_map_core/src/engine/map_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../../domain/entities/crop_issue_entity.dart';
import '../../domain/entities/gps_track_entity.dart';
import '../../domain/usecases/get_tracks_usecase.dart';

class TrackDetailScreen extends ConsumerStatefulWidget {
  const TrackDetailScreen({
    super.key,
    required this.trackId,
  });

  final String trackId;

  @override
  ConsumerState<TrackDetailScreen> createState() => _TrackDetailScreenState();
}

class _TrackDetailScreenState extends ConsumerState<TrackDetailScreen> {
  late final MapEngine _mapEngine;
  GPSTrack? _track;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _mapEngine = MapEngine(
      config: const MapConfig(
        styleUrl: 'https://demotiles.maplibre.org/style.json',
        initialZoom: 16.0,
      ),
    );
    _loadTrack();
  }

  Future<void> _loadTrack() async {
    try {
      // In production this would use GetTrackByIdUseCase.
      // For now we get all tracks and filter.
      final useCase = ref.read(getTracksUseCaseProvider);
      final tracks = await useCase();
      final track = tracks.where((t) => t.id == widget.trackId).firstOrNull;
      if (mounted) {
        setState(() {
          _track = track;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
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
        title: const Text('Track Details'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _track == null
              ? const Center(child: Text('Track not found'))
              : _buildContent(context, _track!),
    );
  }

  Widget _buildContent(BuildContext context, GPSTrack track) {
    final dateFormat = DateFormat('MMM d, yyyy h:mm a');

    return Column(
      children: [
        Expanded(
          flex: 3,
          child: _mapEngine.buildMapWidget(
            onMapReady: (controller) {
              // Fit to track bounds when map is ready
              if (track.path.length >= 2) {
                final lats = track.path.map((p) => p.latitude);
                final lngs = track.path.map((p) => p.longitude);
                controller.fitBounds(
                  LatLngBounds(
                    southwest: LatLng(
                      lats.reduce((a, b) => a < b ? a : b),
                      lngs.reduce((a, b) => a < b ? a : b),
                    ),
                    northeast: LatLng(
                      lats.reduce((a, b) => a > b ? a : b),
                      lngs.reduce((a, b) => a > b ? a : b),
                    ),
                  ),
                );
              }
            },
          ),
        ),
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateFormat.format(track.startTime),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _StatCard(
                      label: 'Distance',
                      value: _formatDistance(track.distance),
                      icon: Icons.straighten,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      label: 'Duration',
                      value: _formatDuration(track.duration),
                      icon: Icons.timer_outlined,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      label: 'Avg Speed',
                      value:
                          '${track.averageSpeedKmh.toStringAsFixed(1)} km/h',
                      icon: Icons.speed,
                    ),
                  ],
                ),
                if (track.issues.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Issues (${track.issues.length})',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  ...track.issues.map((issue) => _IssueListItem(issue: issue)),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDistance(double meters) {
    if (meters < 1000) return '${meters.toStringAsFixed(0)} m';
    return '${(meters / 1000).toStringAsFixed(2)} km';
  }

  String _formatDuration(Duration d) {
    if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    return '${d.inMinutes}m';
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20,
                color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 4),
            Text(value,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

class _IssueListItem extends StatelessWidget {
  const _IssueListItem({required this.issue});

  final CropIssue issue;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _severityColor(issue.severity).withValues(alpha: 0.15),
          child: Icon(
            _issueIcon(issue.type),
            color: _severityColor(issue.severity),
            size: 20,
          ),
        ),
        title: Text(issue.type.displayName),
        subtitle: issue.description.isNotEmpty
            ? Text(issue.description, maxLines: 1,
                overflow: TextOverflow.ellipsis)
            : null,
        trailing: Text(
          issue.severity.displayName,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: _severityColor(issue.severity),
              ),
        ),
      ),
    );
  }

  Color _severityColor(CropIssueSeverity s) {
    switch (s) {
      case CropIssueSeverity.low:
        return const Color(0xFF4CAF50);
      case CropIssueSeverity.moderate:
        return const Color(0xFFF9A825);
      case CropIssueSeverity.high:
        return const Color(0xFFFF9800);
      case CropIssueSeverity.critical:
        return const Color(0xFFD32F2F);
    }
  }

  IconData _issueIcon(CropIssueType type) {
    switch (type) {
      case CropIssueType.pest:
        return Icons.bug_report_outlined;
      case CropIssueType.disease:
        return Icons.coronavirus_outlined;
      case CropIssueType.weed:
        return Icons.grass;
      case CropIssueType.nutrientDeficiency:
        return Icons.science_outlined;
      case CropIssueType.waterStress:
        return Icons.water_drop_outlined;
      case CropIssueType.mechanicalDamage:
        return Icons.build_outlined;
      case CropIssueType.wildlife:
        return Icons.pets_outlined;
      case CropIssueType.other:
        return Icons.help_outline;
    }
  }
}

/// Provider reference for dependency injection.
final getTracksUseCaseProvider = Provider<GetTracksUseCase>((ref) {
  throw UnimplementedError(
    'getTracksUseCaseProvider must be overridden in ProviderScope',
  );
});
