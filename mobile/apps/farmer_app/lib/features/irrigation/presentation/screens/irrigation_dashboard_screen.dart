import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/irrigation_zone_entity.dart';
import '../bloc/irrigation_bloc.dart';
import '../bloc/irrigation_event.dart';
import '../bloc/irrigation_state.dart';
import '../widgets/irrigation_alert_tile.dart';
import '../widgets/moisture_indicator.dart';
import 'irrigation_schedule_screen.dart';
import 'irrigation_zone_detail_screen.dart';

class IrrigationDashboardScreen extends StatefulWidget {
  const IrrigationDashboardScreen({
    super.key,
    required this.fieldId,
  });

  final String fieldId;
  static const String routePath = '/irrigation';

  @override
  State<IrrigationDashboardScreen> createState() =>
      _IrrigationDashboardScreenState();
}

class _IrrigationDashboardScreenState extends State<IrrigationDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<IrrigationBloc>().add(LoadZones(fieldId: widget.fieldId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Irrigation'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Zones'),
            Tab(text: 'Schedule'),
            Tab(text: 'Alerts'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context
                  .read<IrrigationBloc>()
                  .add(LoadZones(fieldId: widget.fieldId));
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ZonesTab(fieldId: widget.fieldId),
          _ScheduleTab(fieldId: widget.fieldId),
          _AlertsTab(),
        ],
      ),
    );
  }
}

class _ZonesTab extends StatelessWidget {
  const _ZonesTab({required this.fieldId});

  final String fieldId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<IrrigationBloc, IrrigationState>(
      builder: (context, state) {
        if (state is IrrigationLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is IrrigationError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                const SizedBox(height: 16),
                Text(state.message),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => context
                      .read<IrrigationBloc>()
                      .add(LoadZones(fieldId: fieldId)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        if (state is ZonesLoaded) {
          if (state.zones.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.water_drop_outlined,
                      size: 64,
                      color: colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text('No irrigation zones configured',
                      style: theme.textTheme.titleMedium),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              context
                  .read<IrrigationBloc>()
                  .add(LoadZones(fieldId: fieldId));
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _ZoneSummaryHeader(
                  total: state.zones.length,
                  active: state.activeCount,
                  needsIrrigation: state.needsIrrigationCount,
                ),
                const SizedBox(height: 16),
                ...state.zones.map(
                  (zone) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ZoneCard(
                      zone: zone,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => BlocProvider.value(
                            value: context.read<IrrigationBloc>(),
                            child:
                                IrrigationZoneDetailScreen(zoneId: zone.id),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _ZoneSummaryHeader extends StatelessWidget {
  const _ZoneSummaryHeader({
    required this.total,
    required this.active,
    required this.needsIrrigation,
  });

  final int total;
  final int active;
  final int needsIrrigation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatColumn(label: 'Zones', value: '$total', color: colorScheme.primary),
          _StatColumn(label: 'Active', value: '$active', color: Colors.green),
          _StatColumn(
            label: 'Needs Water',
            value: '$needsIrrigation',
            color: Colors.orange,
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ZoneCard extends StatelessWidget {
  const _ZoneCard({required this.zone, this.onTap});

  final IrrigationZone zone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusColor = _statusColor(zone.status);

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.water_drop,
                        color: Colors.blue, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      zone.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      zone.status.name.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              MoistureIndicator(
                currentMoisture: zone.currentMoisture,
                targetMoisture: zone.targetMoisture,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Color _statusColor(IrrigationZoneStatus status) {
    return switch (status) {
      IrrigationZoneStatus.active => Colors.green,
      IrrigationZoneStatus.inactive => Colors.grey,
      IrrigationZoneStatus.irrigating => Colors.blue,
      IrrigationZoneStatus.scheduled => Colors.orange,
      IrrigationZoneStatus.error => Colors.red,
    };
  }
}

class _ScheduleTab extends StatelessWidget {
  const _ScheduleTab({required this.fieldId});

  final String fieldId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule,
              size: 64,
              color:
                  theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text('Select a zone to view schedules',
              style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
          FilledButton.tonalIcon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => BlocProvider.value(
                    value: context.read<IrrigationBloc>(),
                    child: const IrrigationScheduleScreen(),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.calendar_month),
            label: const Text('View All Schedules'),
          ),
        ],
      ),
    );
  }
}

class _AlertsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<IrrigationBloc, IrrigationState>(
      builder: (context, state) {
        if (state is AlertsLoaded) {
          if (state.alerts.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_none,
                      size: 64,
                      color: theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text('No alerts', style: theme.textTheme.bodyMedium),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: state.alerts.length,
            itemBuilder: (context, index) {
              return IrrigationAlertTile(alert: state.alerts[index]);
            },
          );
        }

        // Default: trigger loading alerts
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            context.read<IrrigationBloc>().add(const LoadAlerts());
          }
        });
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
