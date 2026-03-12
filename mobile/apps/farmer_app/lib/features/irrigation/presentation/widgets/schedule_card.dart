import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/irrigation_schedule_entity.dart';

class ScheduleCard extends StatelessWidget {
  const ScheduleCard({
    super.key,
    required this.schedule,
    this.zoneName,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final IrrigationSchedule schedule;
  final String? zoneName;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('HH:mm');
    final (statusColor, statusLabel) = _statusDisplay(schedule.status);

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (onEdit != null)
                    IconButton(
                      icon: const Icon(Icons.edit, size: 18),
                      onPressed: onEdit,
                      visualDensity: VisualDensity.compact,
                    ),
                  if (onDelete != null)
                    IconButton(
                      icon: Icon(Icons.delete_outline,
                          size: 18, color: colorScheme.error),
                      onPressed: onDelete,
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (zoneName != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    zoneName!,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              Row(
                children: [
                  Icon(Icons.calendar_today,
                      size: 14, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text(
                    dateFormat.format(schedule.startTime),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _InfoChip(
                    icon: Icons.access_time,
                    label:
                        '${timeFormat.format(schedule.startTime)} - ${timeFormat.format(schedule.endTime)}',
                  ),
                  const SizedBox(width: 12),
                  _InfoChip(
                    icon: Icons.timer,
                    label: schedule.durationFormatted,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              _InfoChip(
                icon: Icons.water_drop,
                label: '${schedule.waterVolume.toStringAsFixed(1)} L',
              ),
            ],
          ),
        ),
      ),
    );
  }

  static (Color, String) _statusDisplay(ScheduleStatus status) {
    return switch (status) {
      ScheduleStatus.pending => (Colors.blue, 'Pending'),
      ScheduleStatus.active => (Colors.green, 'Active'),
      ScheduleStatus.completed => (Colors.grey, 'Completed'),
      ScheduleStatus.cancelled => (Colors.red, 'Cancelled'),
      ScheduleStatus.paused => (Colors.orange, 'Paused'),
    };
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
