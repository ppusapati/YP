import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/advisory_entity.dart';
import '../bloc/crop_advisory_bloc.dart';
import '../bloc/crop_advisory_event.dart';
import '../bloc/crop_advisory_state.dart';

/// Screen listing crop advisories.
class CropAdvisoryScreen extends StatefulWidget {
  const CropAdvisoryScreen({super.key});

  @override
  State<CropAdvisoryScreen> createState() => _CropAdvisoryScreenState();
}

class _CropAdvisoryScreenState extends State<CropAdvisoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CropAdvisoryBloc>().add(const LoadAdvisories());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<CropAdvisoryBloc, CropAdvisoryState>(
      builder: (context, state) {
        if (state is CropAdvisoryLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is CropAdvisoryError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                const SizedBox(height: 16),
                Text(state.message),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => context
                      .read<CropAdvisoryBloc>()
                      .add(const LoadAdvisories()),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        if (state is AdvisoriesLoaded) {
          if (state.advisories.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.agriculture,
                      size: 80,
                      color:
                          colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
                  const SizedBox(height: 24),
                  Text('No advisories yet',
                      style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(
                    'Crop advisories will appear here\nonce they are created.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              context.read<CropAdvisoryBloc>().add(const LoadAdvisories());
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.advisories.length,
              itemBuilder: (context, index) {
                final advisory = state.advisories[index];
                return _AdvisoryCard(advisory: advisory);
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _AdvisoryCard extends StatelessWidget {
  const _AdvisoryCard({required this.advisory});

  final AdvisoryEntity advisory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: advisory.isHighPriority
                        ? colorScheme.errorContainer
                        : colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    advisory.cropName,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: advisory.isHighPriority
                          ? colorScheme.onErrorContainer
                          : colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat.yMMMd().format(advisory.plantingDate),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              advisory.recommendation,
              style: theme.textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
