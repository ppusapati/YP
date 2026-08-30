import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/prescription_bloc.dart';

/// Form screen for generating a new prescription: select field, crop,
/// target yield, and optional soil data entry.
class GeneratePrescriptionScreen extends StatefulWidget {
  const GeneratePrescriptionScreen({super.key});

  @override
  State<GeneratePrescriptionScreen> createState() =>
      _GeneratePrescriptionScreenState();
}

class _GeneratePrescriptionScreenState
    extends State<GeneratePrescriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fieldIdController = TextEditingController();
  final _targetYieldController = TextEditingController();
  final _soilDataController = TextEditingController();

  String _selectedCrop = '';

  static const _cropTypes = [
    'Corn',
    'Soybean',
    'Wheat',
    'Cotton',
    'Rice',
    'Barley',
    'Sorghum',
    'Canola',
  ];

  @override
  void dispose() {
    _fieldIdController.dispose();
    _targetYieldController.dispose();
    _soilDataController.dispose();
    super.dispose();
  }

  List<List<double>>? _parseSoilData() {
    final text = _soilDataController.text.trim();
    if (text.isEmpty) return null;
    try {
      final lines = text.split('\n').where((l) => l.trim().isNotEmpty);
      return lines.map((line) {
        return line
            .split(RegExp(r'[,\t\s]+'))
            .map((v) => double.parse(v.trim()))
            .toList();
      }).toList();
    } catch (_) {
      return null;
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final targetYield =
        double.tryParse(_targetYieldController.text.trim());
    if (targetYield == null) return;

    context.read<PrescriptionBloc>().add(GeneratePrescription(
          fieldId: _fieldIdController.text.trim(),
          cropType: _selectedCrop,
          targetYield: targetYield,
          soilData: _parseSoilData(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Generate Prescription')),
      body: BlocConsumer<PrescriptionBloc, PrescriptionState>(
        listener: (context, state) {
          if (state is PrescriptionGenerated) {
            context.go('/prescriptions/${state.prescription.id}');
          }
          if (state is PrescriptionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is PrescriptionLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _fieldIdController,
                    decoration: const InputDecoration(
                      labelText: 'Field ID',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty
                            ? 'Field ID is required'
                            : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedCrop.isEmpty
                        ? null
                        : _selectedCrop,
                    decoration: const InputDecoration(
                      labelText: 'Crop Type',
                      border: OutlineInputBorder(),
                    ),
                    items: _cropTypes
                        .map((c) => DropdownMenuItem(
                            value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedCrop = v ?? ''),
                    validator: (v) =>
                        v == null || v.isEmpty
                            ? 'Please select a crop'
                            : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _targetYieldController,
                    decoration: const InputDecoration(
                      labelText: 'Target Yield (t/ha)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(
                            decimal: true),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Target yield is required';
                      }
                      if (double.tryParse(v.trim()) == null) {
                        return 'Enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _soilDataController,
                    decoration: const InputDecoration(
                      labelText: 'Soil Data Grid (optional)',
                      helperText:
                          'Enter comma-separated values, one row per line',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: isLoading ? null : _submit,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2),
                          )
                        : const Text('Generate Prescription'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
