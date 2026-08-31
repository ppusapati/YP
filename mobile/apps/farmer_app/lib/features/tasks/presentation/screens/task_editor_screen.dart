import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/task_entity.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';

/// Create or edit a farm task with all fields and a map location picker.
class TaskEditorScreen extends StatefulWidget {
  const TaskEditorScreen({
    super.key,
    required this.farmId,
    this.existingTask,
  });

  final String farmId;
  final FarmTask? existingTask;

  bool get isEditing => existingTask != null;

  @override
  State<TaskEditorScreen> createState() => _TaskEditorScreenState();
}

class _TaskEditorScreenState extends State<TaskEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _assigneeController;

  late TaskType _taskType;
  late TaskPriority _priority;
  late DateTime _dueDate;
  ll.LatLng? _selectedLocation;
  MapLibreMapController? _mapController;

  @override
  void initState() {
    super.initState();
    final task = widget.existingTask;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController =
        TextEditingController(text: task?.description ?? '');
    _assigneeController = TextEditingController(text: task?.assignee ?? '');
    _taskType = task?.taskType ?? TaskType.other;
    _priority = task?.priority ?? TaskPriority.medium;
    _dueDate = task?.dueDate ?? DateTime.now().add(const Duration(days: 7));
    _selectedLocation = task?.location;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _assigneeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Task' : 'New Task'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Enter task title',
                prefixIcon: Icon(Icons.title),
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Title is required' : null,
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Describe the task...',
                prefixIcon: Icon(Icons.description_outlined),
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            // Task type
            Text('Task Type', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: TaskType.values.map((type) {
                return ChoiceChip(
                  label: Text(type.label),
                  selected: _taskType == type,
                  onSelected: (_) => setState(() => _taskType = type),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Priority
            Text('Priority', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            SegmentedButton<TaskPriority>(
              segments: TaskPriority.values
                  .map((p) => ButtonSegment(
                        value: p,
                        label: Text(p.label),
                      ))
                  .toList(),
              selected: {_priority},
              onSelectionChanged: (v) => setState(() => _priority = v.first),
            ),
            const SizedBox(height: 16),

            // Due date
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined),
              title: const Text('Due Date'),
              subtitle: Text(dateFormat.format(_dueDate)),
              trailing: const Icon(Icons.chevron_right),
              onTap: _pickDueDate,
            ),
            const Divider(),

            // Assignee
            TextFormField(
              controller: _assigneeController,
              decoration: const InputDecoration(
                labelText: 'Assignee (optional)',
                hintText: 'Who should do this?',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Location picker
            Text('Location (optional)', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 200,
                child: Stack(
                  children: [
                    MapLibreMap(
                      styleString:
                          'https://api.maptiler.com/maps/basic-v2/style.json?key=placeholder',
                      initialCameraPosition: CameraPosition(
                        target: _selectedLocation != null
                            ? LatLng(
                                _selectedLocation!.latitude,
                                _selectedLocation!.longitude,
                              )
                            : const LatLng(-1.286389, 36.817223),
                        zoom: 13,
                      ),
                      onMapCreated: (controller) {
                        _mapController = controller;
                        if (_selectedLocation != null) {
                          _addMarker();
                        }
                      },
                      onMapClick: (point, latLng) {
                        setState(() {
                          _selectedLocation =
                              ll.LatLng(latLng.latitude, latLng.longitude);
                        });
                        _addMarker();
                      },
                    ),
                    // Crosshair hint
                    if (_selectedLocation == null)
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Tap to set location',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (_selectedLocation != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    setState(() => _selectedLocation = null);
                    _mapController?.clearSymbols();
                  },
                  child: const Text('Clear location'),
                ),
              ),

            const SizedBox(height: 32),

            // Submit
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: _submit,
                child: Text(widget.isEditing ? 'Update Task' : 'Create Task'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _addMarker() {
    if (_mapController == null || _selectedLocation == null) return;
    _mapController!.clearSymbols();
    _mapController!.addSymbol(SymbolOptions(
      geometry: LatLng(
        _selectedLocation!.latitude,
        _selectedLocation!.longitude,
      ),
      iconImage: 'marker-15',
      iconSize: 2.0,
    ));
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final task = FarmTask(
      id: widget.existingTask?.id ?? const Uuid().v4(),
      farmId: widget.farmId,
      fieldId: widget.existingTask?.fieldId ?? widget.farmId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      taskType: _taskType,
      status: widget.existingTask?.status ?? TaskStatus.pending,
      priority: _priority,
      dueDate: _dueDate,
      location: _selectedLocation,
      assignee: _assigneeController.text.trim().isNotEmpty
          ? _assigneeController.text.trim()
          : null,
      completedDate: widget.existingTask?.completedDate,
      createdAt: widget.existingTask?.createdAt ?? DateTime.now(),
    );

    if (widget.isEditing) {
      context.read<TaskBloc>().add(UpdateTask(task));
    } else {
      context.read<TaskBloc>().add(CreateTask(task));
    }

    Navigator.pop(context);
  }
}
