import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/satellite_bloc.dart';
import '../bloc/satellite_event.dart';
import '../bloc/satellite_state.dart';
import '../widgets/stress_alert_card.dart';

/// Screen listing stress alerts from satellite monitoring.
class StressAlertsScreen extends StatefulWidget {
  const StressAlertsScreen({super.key, required this.farmId});

  final String farmId;

  @override
  State<StressAlertsScreen> createState() => _StressAlertsScreenState();
}

class _StressAlertsScreenState extends State<StressAlertsScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<SatelliteBloc>()
        .add(LoadStressAlerts(farmId: widget.farmId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Stress Alerts')),
      body: BlocBuilder<SatelliteBloc, SatelliteState>(
        builder: (context, state) {
          if (state is SatelliteLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SatelliteError) {
            return Center(child: Text(state.message));
          }
          if (state is StressAlertsLoaded) {
            if (state.alerts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 80, color: Colors.green.withValues(alpha: 0.6)),
                    const SizedBox(height: 24),
                    Text('No stress alerts',
                        style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text(
                      'All fields are looking healthy.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.alerts.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: StressAlertCard(alert: state.alerts[index]),
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
