import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/gps_tracking_bloc.dart';
import '../bloc/gps_tracking_event.dart';
import '../bloc/gps_tracking_state.dart';

class TrackingControls extends StatelessWidget {
  const TrackingControls({
    super.key,
    required this.fieldId,
    this.onIssuePressed,
  });

  final String fieldId;
  final VoidCallback? onIssuePressed;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GPSTrackingBloc, GPSTrackingState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _buildButtons(context, state),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildButtons(BuildContext context, GPSTrackingState state) {
    if (state is TrackingInitial || state is TrackingStopped) {
      return [
        _ControlButton(
          icon: Icons.play_arrow_rounded,
          label: 'Start',
          color: Theme.of(context).colorScheme.primary,
          onPressed: () {
            context.read<GPSTrackingBloc>().add(StartTracking(fieldId));
          },
          isLarge: true,
        ),
      ];
    }

    if (state is TrackingActive) {
      return [
        _ControlButton(
          icon: Icons.pause_rounded,
          label: 'Pause',
          color: Theme.of(context).colorScheme.tertiary,
          onPressed: () {
            context.read<GPSTrackingBloc>().add(const PauseTracking());
          },
        ),
        _ControlButton(
          icon: Icons.report_problem_outlined,
          label: 'Issue',
          color: Theme.of(context).colorScheme.error,
          onPressed: onIssuePressed,
        ),
        _ControlButton(
          icon: Icons.stop_rounded,
          label: 'Stop',
          color: Theme.of(context).colorScheme.error,
          onPressed: () {
            context.read<GPSTrackingBloc>().add(const StopTracking());
          },
        ),
      ];
    }

    if (state is TrackingPaused) {
      return [
        _ControlButton(
          icon: Icons.play_arrow_rounded,
          label: 'Resume',
          color: Theme.of(context).colorScheme.primary,
          onPressed: () {
            context.read<GPSTrackingBloc>().add(const ResumeTracking());
          },
        ),
        _ControlButton(
          icon: Icons.stop_rounded,
          label: 'Stop',
          color: Theme.of(context).colorScheme.error,
          onPressed: () {
            context.read<GPSTrackingBloc>().add(const StopTracking());
          },
        ),
      ];
    }

    return [];
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onPressed,
    this.isLarge = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;
  final bool isLarge;

  @override
  Widget build(BuildContext context) {
    final size = isLarge ? 72.0 : 56.0;
    final iconSize = isLarge ? 36.0 : 28.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: FloatingActionButton(
            heroTag: label,
            onPressed: onPressed,
            backgroundColor: color,
            foregroundColor: Colors.white,
            elevation: 4,
            child: Icon(icon, size: iconSize),
          ),
        ),
        const SizedBox(height: 6),
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
