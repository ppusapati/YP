import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/pest_risk_bloc.dart';
import '../bloc/pest_risk_event.dart';
import '../bloc/pest_risk_state.dart';

/// Screen listing pest alerts across all fields.
class PestAlertListScreen extends StatefulWidget {
  const PestAlertListScreen({super.key});

  @override
  State<PestAlertListScreen> createState() => _PestAlertListScreenState();
}

class _PestAlertListScreenState extends State<PestAlertListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PestRiskBloc>().add(const LoadPestAlerts());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Pest Alerts')),
      body: BlocBuilder<PestRiskBloc, PestRiskState>(
        builder: (context, state) {
          if (state is PestRiskLoading) return const Center(child: CircularProgressIndicator());
          if (state is PestRiskError) return Center(child: Text(state.message));
          if (state is PestRisksLoaded) {
            if (state.risks.isEmpty) {
              return Center(
                child: Text('No active pest alerts', style: theme.textTheme.titleMedium),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.risks.length,
              itemBuilder: (context, index) {
                final alert = state.risks[index];
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.warning_amber, color: theme.colorScheme.error),
                    title: Text(alert.pestType),
                    subtitle: Text('Field: ${alert.fieldId} - ${alert.riskLevel.displayName}'),
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
