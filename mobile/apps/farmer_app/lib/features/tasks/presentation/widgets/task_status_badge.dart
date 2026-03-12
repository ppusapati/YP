import 'package:flutter/material.dart';
import 'package:flutter_ui_core/flutter_ui_core.dart';

import '../../domain/entities/task_entity.dart';

/// A badge displaying the current [TaskStatus] with appropriate color coding.
class TaskStatusBadge extends StatelessWidget {
  const TaskStatusBadge({
    super.key,
    required this.status,
    this.isOverdue = false,
  });

  final TaskStatus status;
  final bool isOverdue;

  Color get _backgroundColor => switch (status) {
        TaskStatus.pending =>
          isOverdue ? AppColors.error : const Color(0xFFFFF3E0),
        TaskStatus.inProgress => const Color(0xFFE3F2FD),
        TaskStatus.completed => AppColors.successContainer,
        TaskStatus.cancelled => const Color(0xFFF5F5F5),
      };

  Color get _textColor => switch (status) {
        TaskStatus.pending =>
          isOverdue ? AppColors.onError : const Color(0xFFE65100),
        TaskStatus.inProgress => const Color(0xFF0D47A1),
        TaskStatus.completed => const Color(0xFF1B5E20),
        TaskStatus.cancelled => const Color(0xFF616161),
      };

  IconData get _icon => switch (status) {
        TaskStatus.pending =>
          isOverdue ? Icons.warning_amber : Icons.schedule_outlined,
        TaskStatus.inProgress => Icons.play_circle_outline,
        TaskStatus.completed => Icons.check_circle_outline,
        TaskStatus.cancelled => Icons.cancel_outlined,
      };

  String get _label {
    if (status == TaskStatus.pending && isOverdue) return 'Overdue';
    return status.label;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 14, color: _textColor),
          const SizedBox(width: 4),
          Text(
            _label,
            style: TextStyle(
              color: _textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
