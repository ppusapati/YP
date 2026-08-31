import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/pest_risk_entity.dart';
import '../bloc/pest_risk_bloc.dart';
import '../bloc/pest_risk_event.dart';
import '../bloc/pest_risk_state.dart';

/// Screen showing pest risk predictions for a field.
class PestRiskScreen extends StatefulWidget {
  const PestRiskScreen({super.key, required this.fieldId});
  final String fieldId;

  @override
  State<PestRiskScreen> createState() => _PestRiskScreenState();
}

class _PestRiskScreenState extends State<PestRiskScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PestRiskBloc>().add(LoadPestRisks(fieldId: widget.fieldId));
  }

  Color _riskColor(RiskLevel level, ColorScheme cs) => switch (level) {
        RiskLevel.critical => cs.error,
        RiskLevel.high => Colors.deepOrange,
        RiskLevel.moderate => Colors.orange,
        RiskLevel.low => Colors.green,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Pest Risk')),
      body: BlocBuilder<PestRiskBloc, PestRiskState>(
        builder: (context, state) {
          if (state is PestRiskLoading) return const Center(child: CircularProgressIndicator());
          if (state is PestRiskError) return Center(child: Text(state.message));
          if (state is PestRisksLoaded) {
            if (state.risks.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, size: 80, color: Colors.green.withValues(alpha: 0.6)),
                    const SizedBox(height: 24),
                    Text('No pest risks detected', style: theme.textTheme.headlineSmall),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.risks.length,
              itemBuilder: (context, index) {
                final risk = state.risks[index];
                final color = _riskColor(risk.riskLevel, colorScheme);
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: color.withValues(alpha: 0.5)),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.bug_report, color: color),
                    title: Text(risk.pestType),
                    subtitle: Text('${risk.riskLevel.displayName} risk - ${risk.probabilityPercent}'),
                    trailing: Text(risk.description, style: theme.textTheme.bodySmall),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
