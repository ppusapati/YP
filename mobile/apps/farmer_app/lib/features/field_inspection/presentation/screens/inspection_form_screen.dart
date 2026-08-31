import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/inspection_entity.dart';
import '../bloc/field_inspection_bloc.dart';
import '../bloc/field_inspection_event.dart';
import '../bloc/field_inspection_state.dart';

/// Screen for creating a new field inspection.
class InspectionFormScreen extends StatefulWidget {
  const InspectionFormScreen({super.key});

  @override
  State<InspectionFormScreen> createState() => _InspectionFormScreenState();
}

class _InspectionFormScreenState extends State<InspectionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _fieldIdController = TextEditingController();
  final _farmIdController = TextEditingController();
  double _healthScore = 75;

  @override
  void dispose() {
    _notesController.dispose();
    _fieldIdController.dispose();
    _farmIdController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final inspection = InspectionEntity(
      id: const Uuid().v4(),
      fieldId: _fieldIdController.text.trim(),
      farmId: _farmIdController.text.trim(),
      date: DateTime.now(),
      notes: _notesController.text.trim(),
      healthScore: _healthScore,
      status: 'draft',
    );

    context
        .read<FieldInspectionBloc>()
        .add(CreateInspection(inspection: inspection));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('New Inspection')),
      body: BlocListener<FieldInspectionBloc, FieldInspectionState>(
        listener: (context, state) {
          if (state is InspectionCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Inspection created'),
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.pop();
          } else if (state is FieldInspectionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _farmIdController,
                  decoration: const InputDecoration(
                    labelText: 'Farm ID',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Farm ID is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _fieldIdController,
                  decoration: const InputDecoration(
                    labelText: 'Field ID',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Field ID is required' : null,
                ),
                const SizedBox(height: 16),
                Text('Health Score: ${_healthScore.toInt()}',
                    style: theme.textTheme.titleSmall),
                Slider(
                  value: _healthScore,
                  min: 0,
                  max: 100,
                  divisions: 100,
                  label: _healthScore.toInt().toString(),
                  onChanged: (v) => setState(() => _healthScore = v),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _submit,
                  child: const Text('Create Inspection'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
