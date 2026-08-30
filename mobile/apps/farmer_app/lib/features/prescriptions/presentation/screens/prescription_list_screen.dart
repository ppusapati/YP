import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/prescription_entity.dart';
import '../bloc/prescription_bloc.dart';

/// Screen listing prescription bundles with field name, crop type, date,
/// and cost savings badge.
class PrescriptionListScreen extends StatefulWidget {
  const PrescriptionListScreen({super.key});

  @override
  State<PrescriptionListScreen> createState() =>
      _PrescriptionListScreenState();
}

class _PrescriptionListScreenState extends State<PrescriptionListScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<PrescriptionBloc>()
        .add(const LoadPrescriptions());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Prescriptions')),
      body: BlocBuilder<PrescriptionBloc, PrescriptionState>(
        builder: (context, state) {
          if (state is PrescriptionLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is PrescriptionError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline,
                      size: 48, color: theme.colorScheme.error),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => context
                        .read<PrescriptionBloc>()
                        .add(const LoadPrescriptions()),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is PrescriptionsLoaded) {
            if (state.prescriptions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.map_outlined,
                        size: 80,
                        color: theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.4)),
                    const SizedBox(height: 24),
                    Text('No prescriptions yet',
                        style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text(
                      'Generate your first prescription\nto optimize input rates.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<PrescriptionBloc>()
                    .add(const LoadPrescriptions());
              },
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: state.prescriptions.length,
                itemBuilder: (context, index) {
                  final bundle = state.prescriptions[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _PrescriptionBundleCard(
                      bundle: bundle,
                      onTap: () =>
                          context.push('/prescriptions/${bundle.id}'),
                    ),
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/prescriptions/generate'),
        icon: const Icon(Icons.add),
        label: const Text('Generate'),
      ),
    );
  }
}

class _PrescriptionBundleCard extends StatelessWidget {
  const _PrescriptionBundleCard({
    required this.bundle,
    this.onTap,
  });

  final PrescriptionBundle bundle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bundle.fieldName.isNotEmpty
                          ? bundle.fieldName
                          : 'Field ${bundle.fieldId}',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${bundle.cropType} · ${DateFormat.yMMMd().format(bundle.createdAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (bundle.prescriptions.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: bundle.prescriptions
                              .map((p) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: colorScheme
                                          .surfaceContainerHighest,
                                      borderRadius:
                                          BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      p.prescriptionType.displayName,
                                      style:
                                          theme.textTheme.labelSmall,
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                  ],
                ),
              ),
              if (bundle.estimatedCostSavings != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '\$${bundle.estimatedCostSavings!.toStringAsFixed(0)}',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'savings',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.green,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
