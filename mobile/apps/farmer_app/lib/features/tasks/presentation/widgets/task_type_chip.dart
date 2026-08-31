import 'package:flutter/material.dart';

import '../../domain/entities/task_entity.dart';

/// A colored chip representing a [TaskType].
class TaskTypeChip extends StatelessWidget {
  const TaskTypeChip({
    super.key,
    required this.taskType,
    this.selected = false,
    this.onTap,
  });

  final TaskType taskType;
  final bool selected;
  final VoidCallback? onTap;

  Color get _color => switch (taskType) {
        TaskType.spraying => const Color(0xFF7B1FA2),
        TaskType.fertilizer => const Color(0xFF388E3C),
        TaskType.irrigation => const Color(0xFF0288D1),
        TaskType.harvesting => const Color(0xFFF57C00),
        TaskType.scouting => const Color(0xFF5D4037),
        TaskType.planting => const Color(0xFF2E7D32),
        TaskType.soilPrep => const Color(0xFF795548),
        TaskType.maintenance => const Color(0xFF616161),
        TaskType.other => const Color(0xFF9E9E9E),
      };

  IconData get _icon => switch (taskType) {
        TaskType.spraying => Icons.sanitizer_outlined,
        TaskType.fertilizer => Icons.eco_outlined,
        TaskType.irrigation => Icons.water_drop_outlined,
        TaskType.harvesting => Icons.agriculture_outlined,
        TaskType.scouting => Icons.search_outlined,
        TaskType.planting => Icons.grass_outlined,
        TaskType.soilPrep => Icons.landscape_outlined,
        TaskType.maintenance => Icons.build_outlined,
        TaskType.other => Icons.more_horiz,
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        avatar: Icon(_icon, size: 16, color: selected ? Colors.white : _color),
        label: Text(
          taskType.label,
          style: TextStyle(
            color: selected ? Colors.white : _color,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        backgroundColor:
            selected ? _color : _color.withValues(alpha: 0.12),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
