import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/alert_entity.dart';
import '../bloc/alert_bloc.dart';
import '../bloc/alert_event.dart';
import '../bloc/alert_state.dart';
import '../widgets/alert_card.dart';

/// Alert feed screen showing a filterable list of alerts with
/// severity-colored cards and pull-to-refresh.
class AlertFeedScreen extends StatelessWidget {
  const AlertFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Alert settings',
            onPressed: () => context.push('/alerts/settings'),
          ),
          BlocBuilder<AlertBloc, AlertState>(
            builder: (context, state) {
              if (state is AlertsLoaded && state.unreadCount > 0) {
                return TextButton(
                  onPressed: () {
                    context.read<AlertBloc>().add(const MarkAllRead());
                  },
                  child: const Text('Mark all read'),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _SeverityFilterChips(),
          _TypeFilterChips(),
          Expanded(
            child: BlocBuilder<AlertBloc, AlertState>(
              builder: (context, state) {
                if (state is AlertLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is AlertError) {
                  return _ErrorView(message: state.message);
                }

                if (state is AlertsLoaded) {
                  final alerts = state.filteredAlerts;

                  if (alerts.isEmpty) {
                    return _EmptyView(hasFilter: state.activeSeverityFilter != null ||
                        state.activeTypeFilter != null);
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<AlertBloc>().add(const RefreshAlerts());
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 4, bottom: 16),
                      itemCount: alerts.length,
                      itemBuilder: (context, index) {
                        final alert = alerts[index];
                        return AlertCard(
                          alert: alert,
                          onTap: () {
                            if (!alert.read) {
                              context.read<AlertBloc>().add(MarkRead(alert.id));
                            }
                            context.push('/alerts/${alert.id}');
                          },
                        );
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SeverityFilterChips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlertBloc, AlertState>(
      buildWhen: (previous, current) =>
          current is AlertsLoaded || current is AlertInitial,
      builder: (context, state) {
        final activeSeverity =
            state is AlertsLoaded ? state.activeSeverityFilter : null;
        final activeType =
            state is AlertsLoaded ? state.activeTypeFilter : null;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: AlertSeverity.values.map((severity) {
              final isSelected = activeSeverity == severity;
              final color = _chipColor(severity);
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(severity.displayName),
                  selected: isSelected,
                  selectedColor: color.withValues(alpha: 0.2),
                  checkmarkColor: color,
                  onSelected: (selected) {
                    context.read<AlertBloc>().add(FilterAlerts(
                          severity: selected ? severity : null,
                          type: activeType,
                        ));
                  },
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Color _chipColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.info:
        return const Color(0xFF0288D1);
      case AlertSeverity.warning:
        return const Color(0xFFF9A825);
      case AlertSeverity.critical:
        return const Color(0xFFE65100);
      case AlertSeverity.emergency:
        return const Color(0xFFD32F2F);
    }
  }
}

class _TypeFilterChips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlertBloc, AlertState>(
      buildWhen: (previous, current) =>
          current is AlertsLoaded || current is AlertInitial,
      builder: (context, state) {
        final activeSeverity =
            state is AlertsLoaded ? state.activeSeverityFilter : null;
        final activeType =
            state is AlertsLoaded ? state.activeTypeFilter : null;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 6),
          child: Row(
            children: AlertType.values.map((type) {
              final isSelected = activeType == type;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(type.displayName),
                  selected: isSelected,
                  onSelected: (selected) {
                    context.read<AlertBloc>().add(FilterAlerts(
                          severity: activeSeverity,
                          type: selected ? type : null,
                        ));
                  },
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load alerts',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: () {
              context.read<AlertBloc>().add(const LoadAlerts());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({this.hasFilter = false});
  final bool hasFilter;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasFilter ? Icons.filter_list_off : Icons.notifications_none,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            hasFilter ? 'No matching alerts' : 'No alerts',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            hasFilter
                ? 'Try adjusting your filters'
                : 'You\'re all caught up!',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
