import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/irrigation_schedule_entity.dart';
import '../bloc/irrigation_bloc.dart';
import '../bloc/irrigation_event.dart';
import '../bloc/irrigation_state.dart';
import '../widgets/schedule_card.dart';

class IrrigationScheduleScreen extends StatelessWidget {
  const IrrigationScheduleScreen({super.key, this.zoneId});

  final String? zoneId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Irrigation Schedule'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showScheduleEditor(context),
        icon: const Icon(Icons.add),
        label: const Text('New Schedule'),
      ),
      body: BlocBuilder<IrrigationBloc, IrrigationState>(
        builder: (context, state) {
          if (state is IrrigationLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is IrrigationError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline,
                      size: 48, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text(state.message),
                ],
              ),
            );
          }
          if (state is ScheduleLoaded) {
            if (state.schedules.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.event_busy,
                        size: 64,
                        color: colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.5)),
                    const SizedBox(height: 16),
                    Text('No schedules yet',
                        style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text('Tap + to create a new irrigation schedule',
                        style: theme.textTheme.bodySmall),
                  ],
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (state.activeSchedules.isNotEmpty) ...[
                  _SectionHeader(title: 'Active', count: state.activeSchedules.length),
                  const SizedBox(height: 8),
                  ...state.activeSchedules.map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ScheduleCard(
                          schedule: s,
                          onEdit: () => _showScheduleEditor(context, schedule: s),
                        ),
                      )),
                  const SizedBox(height: 16),
                ],
                if (state.pendingSchedules.isNotEmpty) ...[
                  _SectionHeader(title: 'Upcoming', count: state.pendingSchedules.length),
                  const SizedBox(height: 8),
                  ...state.pendingSchedules.map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ScheduleCard(
                          schedule: s,
                          onEdit: () => _showScheduleEditor(context, schedule: s),
                        ),
                      )),
                  const SizedBox(height: 16),
                ],
                _SectionHeader(title: 'All Schedules', count: state.schedules.length),
                const SizedBox(height: 8),
                ...state.schedules.map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ScheduleCard(schedule: s),
                    )),
              ],
            );
          }

          // Trigger load if zoneId is provided
          if (zoneId != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                context
                    .read<IrrigationBloc>()
                    .add(LoadSchedule(zoneId: zoneId!));
              }
            });
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  void _showScheduleEditor(
    BuildContext context, {
    IrrigationSchedule? schedule,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _ScheduleEditorSheet(
        schedule: schedule,
        onSave: (updated) {
          context
              .read<IrrigationBloc>()
              .add(UpdateSchedule(schedule: updated));
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      ],
    );
  }
}

class _ScheduleEditorSheet extends StatefulWidget {
  const _ScheduleEditorSheet({this.schedule, required this.onSave});

  final IrrigationSchedule? schedule;
  final ValueChanged<IrrigationSchedule> onSave;

  @override
  State<_ScheduleEditorSheet> createState() => _ScheduleEditorSheetState();
}

class _ScheduleEditorSheetState extends State<_ScheduleEditorSheet> {
  late DateTime _startDate;
  late TimeOfDay _startTime;
  late int _durationMinutes;
  late double _waterVolume;

  @override
  void initState() {
    super.initState();
    final schedule = widget.schedule;
    _startDate = schedule?.startTime ?? DateTime.now().add(const Duration(hours: 1));
    _startTime = schedule != null
        ? TimeOfDay.fromDateTime(schedule.startTime)
        : const TimeOfDay(hour: 6, minute: 0);
    _durationMinutes = schedule?.duration.inMinutes ?? 30;
    _waterVolume = schedule?.waterVolume ?? 100;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.schedule != null;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEditing ? 'Edit Schedule' : 'New Schedule',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Start Date'),
            subtitle: Text(DateFormat('MMM dd, yyyy').format(_startDate)),
            onTap: _pickDate,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('Start Time'),
            subtitle: Text(_startTime.format(context)),
            onTap: _pickTime,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
          ),
          const SizedBox(height: 16),
          Text('Duration: $_durationMinutes minutes',
              style: theme.textTheme.bodyMedium),
          Slider(
            value: _durationMinutes.toDouble(),
            min: 5,
            max: 180,
            divisions: 35,
            label: '$_durationMinutes min',
            onChanged: (value) =>
                setState(() => _durationMinutes = value.round()),
          ),
          const SizedBox(height: 8),
          Text(
              'Water Volume: ${_waterVolume.toStringAsFixed(0)} L',
              style: theme.textTheme.bodyMedium),
          Slider(
            value: _waterVolume,
            min: 10,
            max: 1000,
            divisions: 99,
            label: '${_waterVolume.toStringAsFixed(0)} L',
            onChanged: (value) => setState(() => _waterVolume = value),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _save,
              child: Text(isEditing ? 'Update Schedule' : 'Create Schedule'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) setState(() => _startTime = picked);
  }

  void _save() {
    final startDateTime = DateTime(
      _startDate.year,
      _startDate.month,
      _startDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    final schedule = IrrigationSchedule(
      id: widget.schedule?.id ?? '',
      zoneId: widget.schedule?.zoneId ?? '',
      startTime: startDateTime,
      duration: Duration(minutes: _durationMinutes),
      waterVolume: _waterVolume,
      status: widget.schedule?.status ?? ScheduleStatus.pending,
    );

    widget.onSave(schedule);
  }
}
