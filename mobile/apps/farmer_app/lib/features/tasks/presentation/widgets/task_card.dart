import 'package:flutter/material.dart';
import 'package:flutter_ui_core/flutter_ui_core.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/task_entity.dart';
import 'task_status_badge.dart';
import 'task_type_chip.dart';

/// A list card displaying a [FarmTask] summary with status, priority, and due date.
class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onComplete,
  });

  final FarmTask task;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;

  Color get _priorityColor => switch (task.priority) {
        TaskPriority.low => AppColors.pestLow,
        TaskPriority.medium => AppColors.warning,
        TaskPriority.high => AppColors.pestHigh,
        TaskPriority.urgent => AppColors.error,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, yyyy');

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: task.isOverdue
            ? BorderSide(color: AppColors.error.withValues(alpha: 0.5), width: 1.5)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Priority indicator
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _priorityColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            decoration: task.status == TaskStatus.completed
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (task.description.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            task.description,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (task.status != TaskStatus.completed &&
                      task.status != TaskStatus.cancelled)
                    IconButton(
                      onPressed: onComplete,
                      icon: const Icon(Icons.check_circle_outline),
                      iconSize: 24,
                      color: AppColors.success,
                      tooltip: 'Mark complete',
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  TaskTypeChip(taskType: task.taskType),
                  const SizedBox(width: 8),
                  TaskStatusBadge(
                    status: task.status,
                    isOverdue: task.isOverdue,
                  ),
                  const Spacer(),
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: task.isOverdue
                        ? AppColors.error
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    dateFormat.format(task.dueDate),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: task.isOverdue
                          ? AppColors.error
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight:
                          task.isOverdue ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
              if (task.assignee != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      task.assignee!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
