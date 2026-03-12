import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ui_core/flutter_ui_core.dart';

import '../../domain/entities/task_entity.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import '../widgets/task_card.dart';
import 'task_detail_screen.dart';
import 'task_editor_screen.dart';

/// Main screen listing farm tasks with status/type filtering and a creation FAB.
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key, this.farmId});

  final String? farmId;

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  TaskStatus? _statusFilter;
  TaskType? _typeFilter;

  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(LoadTasks(farmId: widget.farmId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
            tooltip: 'Filter tasks',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<TaskBloc>().add(LoadTasks(farmId: widget.farmId));
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: BlocConsumer<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          if (state is TaskCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Task created successfully'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          if (state is TaskUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Task updated'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TasksLoaded) {
            return _buildTaskList(context, state, theme);
          }

          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.task_outlined, size: 64, color: theme.colorScheme.outline),
                const SizedBox(height: 16),
                Text('No tasks yet', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  'Tap + to create your first task',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToEditor(context),
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
      ),
    );
  }

  Widget _buildTaskList(
    BuildContext context,
    TasksLoaded state,
    ThemeData theme,
  ) {
    final tasks = state.displayTasks;

    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 64, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              'No tasks match your filters',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _clearFilters,
              child: const Text('Clear filters'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Summary bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: theme.colorScheme.surfaceContainerHighest,
          child: Row(
            children: [
              _CountChip(
                label: 'Pending',
                count: state.pendingCount,
                color: AppColors.warning,
              ),
              const SizedBox(width: 8),
              _CountChip(
                label: 'In Progress',
                count: state.inProgressCount,
                color: AppColors.info,
              ),
              const SizedBox(width: 8),
              _CountChip(
                label: 'Overdue',
                count: state.overdueCount,
                color: AppColors.error,
              ),
              const Spacer(),
              Text(
                '${tasks.length} task${tasks.length == 1 ? '' : 's'}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        // Active filter chips
        if (_statusFilter != null || _typeFilter != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                if (_statusFilter != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Chip(
                      label: Text(_statusFilter!.label),
                      onDeleted: () {
                        setState(() => _statusFilter = null);
                        _applyFilters();
                      },
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                if (_typeFilter != null)
                  Chip(
                    label: Text(_typeFilter!.label),
                    onDeleted: () {
                      setState(() => _typeFilter = null);
                      _applyFilters();
                    },
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ),
        // Task list
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<TaskBloc>().add(LoadTasks(farmId: widget.farmId));
            },
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: tasks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final task = tasks[index];
                return TaskCard(
                  task: task,
                  onTap: () => _navigateToDetail(context, task),
                  onComplete: () {
                    context.read<TaskBloc>().add(CompleteTask(task.id));
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Filter Tasks',
                          style: Theme.of(context).textTheme.titleMedium),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          setSheetState(() {
                            _statusFilter = null;
                            _typeFilter = null;
                          });
                          _clearFilters();
                          Navigator.pop(context);
                        },
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Status',
                      style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: TaskStatus.values.map((s) {
                      return ChoiceChip(
                        label: Text(s.label),
                        selected: _statusFilter == s,
                        onSelected: (selected) {
                          setSheetState(() {
                            _statusFilter = selected ? s : null;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Text('Type', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: TaskType.values.map((t) {
                      return ChoiceChip(
                        label: Text(t.label),
                        selected: _typeFilter == t,
                        onSelected: (selected) {
                          setSheetState(() {
                            _typeFilter = selected ? t : null;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        _applyFilters();
                        Navigator.pop(context);
                      },
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _applyFilters() {
    context.read<TaskBloc>().add(FilterTasks(
          status: _statusFilter,
          taskType: _typeFilter,
        ));
  }

  void _clearFilters() {
    setState(() {
      _statusFilter = null;
      _typeFilter = null;
    });
    context.read<TaskBloc>().add(const FilterTasks());
  }

  void _navigateToDetail(BuildContext context, FarmTask task) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: context.read<TaskBloc>(),
          child: TaskDetailScreen(task: task),
        ),
      ),
    );
  }

  void _navigateToEditor(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: context.read<TaskBloc>(),
          child: TaskEditorScreen(farmId: widget.farmId ?? ''),
        ),
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$count $label',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
