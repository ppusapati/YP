import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/alert_entity.dart';
import '../bloc/alert_bloc.dart';
import '../bloc/alert_event.dart';
import '../bloc/alert_state.dart';
import '../widgets/risk_gauge.dart';
import '../widgets/severity_icon.dart';

class AlertDetailScreen extends StatelessWidget {
  const AlertDetailScreen({
    super.key,
    required this.alertId,
  });

  final String alertId;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AlertBloc, AlertState>(
      listenWhen: (previous, current) => current is AlertAcknowledged,
      listener: (context, state) {
        if (state is AlertAcknowledged) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Alert acknowledged')),
          );
        }
      },
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
                // Severity banner
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
                      if (alert.status != AlertStatus.active) ...[
                        const SizedBox(height: 8),
                        Chip(
                          label: Text(alert.status.displayName),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Title and metadata
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
                if (alert.fieldName != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.place_outlined,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        alert.fieldName!,
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                // Message
                Text(
                  alert.message,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),

                // Metric visualization
                if (alert.metrics != null && alert.metrics!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _MetricsSection(metrics: alert.metrics!),
                ],

                // Recommendations
                if (alert.recommendations.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _RecommendationsSection(
                    recommendations: alert.recommendations,
                  ),
                ],

                // Acknowledged info
                if (alert.acknowledgedAt != null) ...[
                  const SizedBox(height: 24),
                  _AcknowledgedInfo(
                    acknowledgedAt: alert.acknowledgedAt!,
                    acknowledgedBy: alert.acknowledgedBy,
                  ),
                ],

                // Action buttons
                const SizedBox(height: 32),
                _ActionButtons(alert: alert),

                if (alert.actionUrl != null) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.push(alert.actionUrl!);
                      },
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('View Related Data'),
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
      case AlertType.soilHealth:
        return Icons.landscape_outlined;
      case AlertType.weatherEvent:
        return Icons.thunderstorm_outlined;
    }
  }
}

class _MetricsSection extends StatelessWidget {
  const _MetricsSection({required this.metrics});
  final Map<String, dynamic> metrics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Metrics',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: metrics.entries.map((entry) {
            final value = entry.value;
            // Show a risk gauge for percentage-like values.
            if (value is num && entry.key.toLowerCase().contains('score')) {
              return SizedBox(
                width: 100,
                child: Column(
                  children: [
                    RiskGauge(
                      score: value.toDouble(),
                      size: 80,
                      strokeWidth: 8,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatKey(entry.key),
                      style: theme.textTheme.labelSmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatKey(entry.key),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$value',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _formatKey(String key) {
    return key
        .replaceAllMapped(RegExp(r'_([a-z])'), (m) => ' ${m[1]!.toUpperCase()}')
        .replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m[1]}')
        .trim()
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}

class _RecommendationsSection extends StatelessWidget {
  const _RecommendationsSection({required this.recommendations});
  final List<String> recommendations;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommendations',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ...recommendations.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${entry.key + 1}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.value,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _AcknowledgedInfo extends StatelessWidget {
  const _AcknowledgedInfo({
    required this.acknowledgedAt,
    this.acknowledgedBy,
  });
  final DateTime acknowledgedAt;
  final String? acknowledgedBy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Acknowledged ${DateFormat('MMM d, h:mm a').format(acknowledgedAt)}'
              '${acknowledgedBy != null ? ' by $acknowledgedBy' : ''}',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.alert});
  final Alert alert;

  @override
  Widget build(BuildContext context) {
    if (alert.isResolved) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        if (alert.isActive) ...[
          Expanded(
            child: FilledButton.icon(
              onPressed: () {
                context
                    .read<AlertBloc>()
                    .add(AcknowledgeAlert(alertId: alert.id));
              },
              icon: const Icon(Icons.check),
              label: const Text('Acknowledge'),
            ),
          ),
        ],
        if (alert.isAcknowledged) ...[
          Expanded(
            child: FilledButton.icon(
              onPressed: () {
                // Resolve goes through the same acknowledge flow
                // with a resolve action on the backend.
                context
                    .read<AlertBloc>()
                    .add(AcknowledgeAlert(alertId: alert.id));
              },
              icon: const Icon(Icons.done_all),
              label: const Text('Resolve'),
            ),
          ),
        ],
      ],
    );
  }
}
