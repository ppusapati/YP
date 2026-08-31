import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/soil_analysis_entity.dart';
import '../bloc/soil_analysis_bloc.dart';
import '../bloc/soil_analysis_event.dart';
import '../bloc/soil_analysis_state.dart';

/// Screen for recording a new soil sample.
class SoilSampleFormScreen extends StatefulWidget {
  const SoilSampleFormScreen({super.key, required this.fieldId});

  final String fieldId;

  @override
  State<SoilSampleFormScreen> createState() => _SoilSampleFormScreenState();
}

class _SoilSampleFormScreenState extends State<SoilSampleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phController = TextEditingController(text: '6.5');
  final _nitrogenController = TextEditingController(text: '0');
  final _phosphorusController = TextEditingController(text: '0');
  final _potassiumController = TextEditingController(text: '0');

  @override
  void dispose() {
    _phController.dispose();
    _nitrogenController.dispose();
    _phosphorusController.dispose();
    _potassiumController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final ph = double.tryParse(_phController.text) ?? 6.5;
    final n = double.tryParse(_nitrogenController.text) ?? 0;
    final p = double.tryParse(_phosphorusController.text) ?? 0;
    final k = double.tryParse(_potassiumController.text) ?? 0;
    final healthScore = _calculateHealthScore(ph, n, p, k);

    final analysis = SoilAnalysisEntity(
      id: const Uuid().v4(),
      fieldId: widget.fieldId,
      pH: ph,
      nitrogen: n,
      phosphorus: p,
      potassium: k,
      healthScore: healthScore,
      sampledAt: DateTime.now(),
    );

    context.read<SoilAnalysisBloc>().add(CreateSoilSample(analysis: analysis));
  }

  double _calculateHealthScore(double ph, double n, double p, double k) {
    double score = 50;
    if (ph >= 6.0 && ph <= 7.5) score += 25;
    if (n >= 20 && n <= 80) score += 10;
    if (p >= 10 && p <= 60) score += 10;
    if (k >= 10 && k <= 60) score += 5;
    return score.clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Soil Sample')),
      body: BlocListener<SoilAnalysisBloc, SoilAnalysisState>(
        listener: (context, state) {
          if (state is SoilSampleCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Soil sample recorded'),
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.pop();
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
                  controller: _phController,
                  decoration: const InputDecoration(
                    labelText: 'pH Level',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final val = double.tryParse(v ?? '');
                    if (val == null || val < 0 || val > 14) {
                      return 'Enter a valid pH (0-14)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nitrogenController,
                  decoration: const InputDecoration(
                    labelText: 'Nitrogen (ppm)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phosphorusController,
                  decoration: const InputDecoration(
                    labelText: 'Phosphorus (ppm)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _potassiumController,
                  decoration: const InputDecoration(
                    labelText: 'Potassium (ppm)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _submit,
                  child: const Text('Record Sample'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
