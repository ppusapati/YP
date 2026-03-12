import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/farm_entity.dart';
import '../bloc/farm_bloc.dart';
import '../bloc/farm_event.dart';
import '../bloc/farm_state.dart';
import '../widgets/farm_card.dart';
import 'farm_detail_screen.dart';
import 'farm_editor_screen.dart';

/// Screen displaying all farms for the current user with search functionality.
class FarmListScreen extends StatefulWidget {
  const FarmListScreen({super.key});

  static const String routePath = '/farms';

  @override
  State<FarmListScreen> createState() => _FarmListScreenState();
}

class _FarmListScreenState extends State<FarmListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FarmEntity> _filterFarms(List<FarmEntity> farms) {
    if (_searchQuery.isEmpty) return farms;
    final query = _searchQuery.toLowerCase();
    return farms.where((farm) {
      return farm.name.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Farms'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<FarmBloc>().add(
                    const LoadFarms(userId: ''),
                  );
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
            child: BlocConsumer<FarmBloc, FarmState>(
              listener: (context, state) {
                if (state is FarmCreated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Farm "${state.farm.name}" created'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else if (state is FarmDeleted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Farm deleted'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is FarmLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is FarmError) {
                  return _ErrorView(
                    message: state.message,
                    onRetry: () {
                      context.read<FarmBloc>().add(
                            const LoadFarms(userId: ''),
                          );
                    },
                  );
                }
                if (state is FarmsLoaded) {
                  final filtered = _filterFarms(state.farms);
                  if (state.farms.isEmpty) {
                    return _EmptyView(
                      onCreateFarm: () => _navigateToEditor(context),
                    );
                  }
                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.5),
                          ),
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
                      context.read<FarmBloc>().add(
                            const LoadFarms(userId: ''),
                          );
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
                            onTap: () => _navigateToDetail(context, farm),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToEditor(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Farm'),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, FarmEntity farm) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: context.read<FarmBloc>(),
          child: FarmDetailScreen(farmId: farm.id),
        ),
      ),
    );
  }

  void _navigateToEditor(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: context.read<FarmBloc>(),
          child: const FarmEditorScreen(),
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.onCreateFarm});

  final VoidCallback onCreateFarm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.agriculture,
              size: 80,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 24),
            Text(
              'No farms yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first farm to start managing\nyour fields and crops.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: onCreateFarm,
              icon: const Icon(Icons.add),
              label: const Text('Create Farm'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text('Failed to load farms', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
