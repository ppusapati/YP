import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/prescription_entity.dart';
import '../bloc/prescription_bloc.dart';
import '../widgets/zone_summary_card.dart';

/// Screen showing zone summary cards, rate ranges, and total amounts
/// per prescription type.
class PrescriptionDetailScreen extends StatefulWidget {
  const PrescriptionDetailScreen({
    super.key,
    required this.prescriptionId,
  });

  final String prescriptionId;

  @override
  State<PrescriptionDetailScreen> createState() =>
      _PrescriptionDetailScreenState();
}

class _PrescriptionDetailScreenState
    extends State<PrescriptionDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PrescriptionBloc>().add(
        LoadPrescriptionDetail(prescriptionId: widget.prescriptionId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Prescription Detail')),
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
                        .add(LoadPrescriptionDetail(
                            prescriptionId: widget.prescriptionId)),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is PrescriptionDetailLoaded) {
            return _buildContent(context, state.prescription);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, PrescriptionBundle bundle) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bundle info
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bundle.fieldName.isNotEmpty
                        ? bundle.fieldName
                        : 'Field ${bundle.fieldId}',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _InfoChip(label: bundle.cropType),
                      const SizedBox(width: 8),
                      _InfoChip(
                          label:
                              'Target: ${bundle.targetYield.toStringAsFixed(1)} t/ha'),
                      if (bundle.estimatedCostSavings != null) ...[
                        const SizedBox(width: 8),
                        _InfoChip(
                          label:
                              '\$${bundle.estimatedCostSavings!.toStringAsFixed(0)} savings',
                          color: Colors.green,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Prescription maps
          for (final rx in bundle.prescriptions) ...[
            Text(
              rx.prescriptionType.displayName,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'Avg rate: ${rx.avgRate.toStringAsFixed(1)} ${rx.unit}/ha',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Total: ${rx.totalAmount.toStringAsFixed(1)} ${rx.unit}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (rx.zones.isNotEmpty)
              ...rx.zones.map((zone) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ZoneSummaryCard(
                      zone: zone,
                      unit: rx.unit,
                    ),
                  ))
            else
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'No zone data available',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipColor = color ?? theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: chipColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
