import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/alert_entity.dart';
import '../bloc/alert_bloc.dart';
import '../bloc/alert_event.dart';
import '../bloc/alert_state.dart';
import '../widgets/alert_list_tile.dart';

class AlertListScreen extends StatelessWidget {
  const AlertListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts'),
        actions: [
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
          _FilterChips(),
          Expanded(
            child: BlocBuilder<AlertBloc, AlertState>(
              builder: (context, state) {
                if (state is AlertLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is AlertError) {
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
                          state.message,
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

                if (state is AlertsLoaded) {
                  final alerts = state.filteredAlerts;

                  if (alerts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.notifications_none,
                            size: 64,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No alerts',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'You\'re all caught up!',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context
                          .read<AlertBloc>()
                          .add(const RefreshAlerts());
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 16),
                      itemCount: alerts.length,
                      itemBuilder: (context, index) {
                        final alert = alerts[index];
                        return AlertListTile(
                          alert: alert,
                          onTap: () {
                            if (!alert.read) {
                              context
                                  .read<AlertBloc>()
                                  .add(MarkRead(alert.id));
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

class _FilterChips extends StatelessWidget {
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              ...AlertSeverity.values.map((severity) {
                final isSelected = activeSeverity == severity;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(severity.displayName),
                    selected: isSelected,
                    onSelected: (selected) {
                      context.read<AlertBloc>().add(FilterAlerts(
                            severity: selected ? severity : null,
                            type: activeType,
                          ));
                    },
                  ),
                );
              }),
              const SizedBox(width: 8),
              ...AlertType.values.map((type) {
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
              }),
            ],
          ),
        );
      },
    );
  }
}
