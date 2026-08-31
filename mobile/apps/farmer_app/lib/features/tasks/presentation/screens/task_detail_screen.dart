import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ui_core/flutter_ui_core.dart';
import 'package:intl/intl.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../../domain/entities/task_entity.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../widgets/task_status_badge.dart';
import '../widgets/task_type_chip.dart';
import 'task_editor_screen.dart';

/// Detail view for a single [FarmTask] with map pin and status actions.
class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key, required this.task});

  final FarmTask task;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          if (task.status != TaskStatus.completed &&
              task.status != TaskStatus.cancelled)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => BlocProvider.value(
                      value: context.read<TaskBloc>(),
                      child: TaskEditorScreen(
                        farmId: task.farmId,
                        existingTask: task,
                      ),
                    ),
                  ),
                );
              },
              tooltip: 'Edit task',
            ),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(task.title, style: theme.textTheme.headlineSmall),
                ),
                TaskStatusBadge(
                  status: task.status,
                  isOverdue: task.isOverdue,
                ),
              ],
            ),
            const SizedBox(height: 12),
            TaskTypeChip(taskType: task.taskType),
            const SizedBox(height: 20),

            // Details
            _InfoTile(
              icon: Icons.flag_outlined,
              label: 'Priority',
              value: task.priority.label,
              valueColor: switch (task.priority) {
                TaskPriority.low => AppColors.pestLow,
                TaskPriority.medium => AppColors.warning,
                TaskPriority.high => AppColors.pestHigh,
                TaskPriority.urgent => AppColors.error,
              },
            ),
            _InfoTile(
              icon: Icons.calendar_today_outlined,
              label: 'Due Date',
              value: dateFormat.format(task.dueDate),
              valueColor: task.isOverdue ? AppColors.error : null,
            ),
            if (task.completedDate != null)
              _InfoTile(
                icon: Icons.check_circle_outline,
                label: 'Completed',
                value: dateFormat.format(task.completedDate!),
                valueColor: AppColors.success,
              ),
            if (task.assignee != null)
              _InfoTile(
                icon: Icons.person_outline,
                label: 'Assignee',
                value: task.assignee!,
              ),
            _InfoTile(
              icon: Icons.landscape_outlined,
              label: 'Field',
              value: task.fieldId,
            ),

            // Description
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text('Description', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  task.description,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                ),
              ),
            ],

            // Map
            if (task.location != null) ...[
              const SizedBox(height: 20),
              Text('Location', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 200,
                  child: MapLibreMap(
                    styleString:
                        'https://api.maptiler.com/maps/basic-v2/style.json?key=placeholder',
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        task.location!.latitude,
                        task.location!.longitude,
                      ),
                      zoom: 15,
                    ),
                    onMapCreated: (controller) {
                      controller.addSymbol(SymbolOptions(
                        geometry: LatLng(
                          task.location!.latitude,
                          task.location!.longitude,
                        ),
                        iconImage: 'marker-15',
                        iconSize: 2.0,
                      ));
                    },
                    myLocationEnabled: false,
                    scrollGesturesEnabled: false,
                    zoomGesturesEnabled: false,
                    rotateGesturesEnabled: false,
                    tiltGesturesEnabled: false,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: task.status != TaskStatus.completed &&
              task.status != TaskStatus.cancelled
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (task.status == TaskStatus.pending)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            context.read<TaskBloc>().add(
                                  UpdateTask(task.copyWith(
                                    status: TaskStatus.inProgress,
                                  )),
                                );
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Start'),
                        ),
                      ),
                    if (task.status == TaskStatus.pending)
                      const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          context
                              .read<TaskBloc>()
                              .add(CompleteTask(task.id));
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('Complete'),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<TaskBloc>().add(DeleteTask(task.id));
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
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
      ),
    );
  }
}
