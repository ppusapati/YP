import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/gps_tracking_bloc.dart';
import '../bloc/gps_tracking_state.dart';

class TrackingStats extends StatelessWidget {
  const TrackingStats({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GPSTrackingBloc, GPSTrackingState>(
      builder: (context, state) {
        double distance = 0;
        Duration duration = Duration.zero;
        double speed = 0;
        int issueCount = 0;

        if (state is TrackingActive) {
          distance = state.track.distance;
          duration = state.track.duration;
          speed = state.track.averageSpeedKmh;
          issueCount = state.track.issues.length;
        } else if (state is TrackingPaused) {
          distance = state.track.distance;
          duration = state.elapsedDuration;
          speed = state.track.averageSpeedKmh;
          issueCount = state.track.issues.length;
        }

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                icon: Icons.straighten,
                value: _formatDistance(distance),
                label: 'Distance',
              ),
              _StatItem(
                icon: Icons.timer_outlined,
                value: _formatDuration(duration),
                label: 'Duration',
              ),
              _StatItem(
                icon: Icons.speed,
                value: '${speed.toStringAsFixed(1)} km/h',
                label: 'Avg Speed',
              ),
              _StatItem(
                icon: Icons.flag_outlined,
                value: issueCount.toString(),
                label: 'Issues',
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    }
    return '${(meters / 1000).toStringAsFixed(2)} km';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
