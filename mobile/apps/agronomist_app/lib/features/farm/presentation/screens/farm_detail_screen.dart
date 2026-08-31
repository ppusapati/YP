import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/farm_bloc.dart';
import '../bloc/farm_event.dart';
import '../bloc/farm_state.dart';
import '../widgets/farm_card.dart';

/// Screen displaying details for a single farm.
class FarmDetailScreen extends StatefulWidget {
  const FarmDetailScreen({super.key, required this.farmId});

  final String farmId;

  @override
  State<FarmDetailScreen> createState() => _FarmDetailScreenState();
}

class _FarmDetailScreenState extends State<FarmDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<FarmBloc>().add(LoadFarmById(farmId: widget.farmId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm Details'),
      ),
      body: BlocBuilder<FarmBloc, FarmState>(
        builder: (context, state) {
          if (state is FarmLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is FarmError) {
            return Center(child: Text(state.message));
          }
          if (state is FarmLoaded) {
            final farm = state.farm;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Farm header card
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(Icons.agriculture,
                                    color: colorScheme.onPrimaryContainer,
                                    size: 32),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(farm.name,
                                        style: theme.textTheme.headlineSmall),
                                    const SizedBox(height: 4),
                                    Text('Owner: ${farm.ownerName}',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                                color: colorScheme
                                                    .onSurfaceVariant)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          FarmStatsRow(farm: farm),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Quick actions
                  Text('Quick Actions',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ActionChip(
                        avatar: const Icon(Icons.satellite_alt, size: 18),
                        label: const Text('Satellite'),
                        onPressed: () => context.push(
                            '/satellite/${farm.id}'),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.water_drop, size: 18),
                        label: const Text('Irrigation'),
                        onPressed: () =>
                            context.push('/irrigation/${farm.id}'),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.science, size: 18),
                        label: const Text('Soil Analysis'),
                        onPressed: () =>
                            context.push('/soil-analysis/${farm.id}'),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.bug_report, size: 18),
                        label: const Text('Pest Risk'),
                        onPressed: () =>
                            context.push('/pest-risk/${farm.id}'),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.trending_up, size: 18),
                        label: const Text('Yield Forecast'),
                        onPressed: () =>
                            context.push('/yield-forecast/${farm.id}'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
