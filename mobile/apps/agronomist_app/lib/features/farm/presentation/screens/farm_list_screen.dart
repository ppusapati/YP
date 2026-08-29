import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/farm_entity.dart';
import '../bloc/farm_bloc.dart';
import '../bloc/farm_event.dart';
import '../bloc/farm_state.dart';
import '../widgets/farm_card.dart';

/// Screen displaying all farms managed by the agronomist.
class FarmListScreen extends StatefulWidget {
  const FarmListScreen({super.key});

  @override
  State<FarmListScreen> createState() => _FarmListScreenState();
}

class _FarmListScreenState extends State<FarmListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<FarmBloc>().add(const LoadFarms());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FarmEntity> _filterFarms(List<FarmEntity> farms) {
    if (_searchQuery.isEmpty) return farms;
    final query = _searchQuery.toLowerCase();
    return farms.where((farm) {
      return farm.name.toLowerCase().contains(query) ||
          farm.ownerName.toLowerCase().contains(query) ||
          farm.location.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Managed Farms'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<FarmBloc>().add(const LoadFarms());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search farms...',
              leading: const Icon(Icons.search),
              trailing: [
                if (_searchQuery.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  ),
              ],
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
              elevation: WidgetStateProperty.all(0),
              backgroundColor:
                  WidgetStateProperty.all(colorScheme.surfaceContainerLow),
            ),
          ),
          Expanded(
            child: BlocBuilder<FarmBloc, FarmState>(
              builder: (context, state) {
                if (state is FarmLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is FarmError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline,
                            size: 48, color: colorScheme.error),
                        const SizedBox(height: 16),
                        Text('Failed to load farms',
                            style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text(state.message,
                            style: theme.textTheme.bodySmall,
                            textAlign: TextAlign.center),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: () {
                            context.read<FarmBloc>().add(const LoadFarms());
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                if (state is FarmsLoaded) {
                  final filtered = _filterFarms(state.farms);
                  if (state.farms.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.agriculture,
                              size: 80,
                              color: colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.4)),
                          const SizedBox(height: 24),
                          Text('No farms assigned',
                              style: theme.textTheme.headlineSmall),
                          const SizedBox(height: 8),
                          Text(
                            'Farms will appear here once they are\nassigned to your account.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off,
                              size: 64,
                              color: colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.5)),
                          const SizedBox(height: 16),
                          Text(
                            'No farms match "$_searchQuery"',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<FarmBloc>().add(const LoadFarms());
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final farm = filtered[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: FarmCard(
                            farm: farm,
                            onTap: () => context.push('/farms/${farm.id}'),
                          ),
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
