import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/alert_entity.dart';
import '../bloc/alert_bloc.dart';
import '../bloc/alert_event.dart';
import '../bloc/alert_state.dart';
import '../widgets/severity_icon.dart';

class AlertDetailScreen extends StatelessWidget {
  const AlertDetailScreen({
    super.key,
    required this.alertId,
  });

  final String alertId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlertBloc, AlertState>(
      builder: (context, state) {
        if (state is! AlertsLoaded) {
          return Scaffold(
            appBar: AppBar(title: const Text('Alert')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final alert = state.alerts.where((a) => a.id == alertId).firstOrNull;

        if (alert == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Alert')),
            body: const Center(child: Text('Alert not found')),
          );
        }

        if (!alert.read) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<AlertBloc>().add(MarkRead(alert.id));
          });
        }

        final severityColor = SeverityIcon.colorForSeverity(alert.severity);
        final bgColor =
            SeverityIcon.backgroundColorForSeverity(alert.severity);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Alert Details'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: bgColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: severityColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      SeverityIcon(severity: alert.severity, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        alert.severity.displayName.toUpperCase(),
                        style:
                            Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: severityColor,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  alert.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMM d, yyyy h:mm a')
                          .format(alert.timestamp),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      _iconForAlertType(alert.type),
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      alert.type.displayName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  alert.message,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                if (alert.actionUrl != null) ...[
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        context.push(alert.actionUrl!);
                      },
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Take Action'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _iconForAlertType(AlertType type) {
    switch (type) {
      case AlertType.cropStress:
        return Icons.grass;
      case AlertType.waterShortage:
        return Icons.water_drop_outlined;
      case AlertType.diseaseOutbreak:
        return Icons.coronavirus_outlined;
      case AlertType.pestOutbreak:
        return Icons.bug_report_outlined;
      case AlertType.irrigationNeeded:
        return Icons.shower_outlined;
      case AlertType.frostWarning:
        return Icons.ac_unit;
    }
  }
}
