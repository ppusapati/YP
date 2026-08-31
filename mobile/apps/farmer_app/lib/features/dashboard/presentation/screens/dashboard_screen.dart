import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../farm/presentation/bloc/farm_bloc.dart';
import '../../../farm/presentation/bloc/farm_event.dart';
import '../../../farm/presentation/bloc/farm_state.dart';

/// Main dashboard screen showing overview stats across all managed farms.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<FarmBloc>().add(const LoadFarms(userId: ''));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/alerts'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<FarmBloc>().add(const LoadFarms(userId: ''));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              Text('Overview',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),

              // Stats grid
              BlocBuilder<FarmBloc, FarmState>(
                builder: (context, state) {
                  final farmCount =
                      state is FarmsLoaded ? state.farms.length : 0;
                  final totalArea = state is FarmsLoaded
                      ? state.farms.fold<double>(
                          0, (sum, f) => sum + f.totalAreaHectares)
                      : 0.0;
                  final totalFields = state is FarmsLoaded
                      ? state.farms
                          .fold<int>(0, (sum, f) => sum + f.fields.length)
                      : 0;

                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.agriculture,
                              label: 'Farms',
                              value: '$farmCount',
                              color: colorScheme.primary,
                              onTap: () => context.push('/farms'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.grid_view,
                              label: 'Fields',
                              value: '$totalFields',
                              color: colorScheme.tertiary,
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.landscape,
                              label: 'Total Area',
                              value: '${totalArea.toStringAsFixed(0)} ha',
                              color: colorScheme.secondary,
                              onTap: () {},
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.assignment,
                              label: 'Inspections',
                              value: '--',
                              color: colorScheme.error,
                              onTap: () => context.push('/inspections'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),

              // Quick Actions
              Text('Quick Actions',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              _QuickActionTile(
                icon: Icons.satellite_alt,
                title: 'Satellite Monitoring',
                subtitle: 'View field imagery and vegetation indices',
                onTap: () => context.push('/farms'),
              ),
              _QuickActionTile(
                icon: Icons.pest_control,
                title: 'Pest Risk Analysis',
                subtitle: 'Check current pest risk levels',
                onTap: () => context.push('/farms'),
              ),
              _QuickActionTile(
                icon: Icons.local_florist,
                title: 'Plant Diagnosis',
                subtitle: 'Identify diseases and disorders',
                onTap: () => context.push('/diagnosis/new'),
              ),
              _QuickActionTile(
                icon: Icons.science,
                title: 'Soil Analysis',
                subtitle: 'View soil health data',
                onTap: () => context.push('/farms'),
              ),
              _QuickActionTile(
                icon: Icons.qr_code_scanner,
                title: 'Traceability',
                subtitle: 'Track crop lifecycle records',
                onTap: () => context.push('/traceability'),
              ),
              _QuickActionTile(
                icon: Icons.checklist,
                title: 'Field Inspections',
                subtitle: 'Manage scheduled inspections',
                onTap: () => context.push('/inspections'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 12),
              Text(value,
                  style: theme.textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(label,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          child: Icon(icon, color: colorScheme.onPrimaryContainer, size: 20),
        ),
        title: Text(title, style: theme.textTheme.titleSmall),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
