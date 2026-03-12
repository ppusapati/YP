import 'package:flutter/material.dart';

import '../../domain/entities/treatment_entity.dart';

/// Card displaying a single treatment recommendation with details.
class TreatmentCard extends StatelessWidget {
  const TreatmentCard({
    super.key,
    required this.treatment,
    this.onTap,
  });

  final TreatmentEntity treatment;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final priorityColor = _priorityColor(treatment.priority);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _typeColor(treatment.type).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _typeIcon(treatment.type),
                      size: 20,
                      color: _typeColor(treatment.type),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          treatment.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          treatment.type.displayName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: priorityColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      treatment.priority.displayName,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: priorityColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                treatment.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (treatment.dosage.isNotEmpty ||
                  treatment.applicationMethod.isNotEmpty ||
                  treatment.timing.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if (treatment.dosage.isNotEmpty)
                      _DetailChip(
                        icon: Icons.medication,
                        label: treatment.dosage,
                        colorScheme: colorScheme,
                      ),
                    if (treatment.applicationMethod.isNotEmpty)
                      _DetailChip(
                        icon: Icons.science,
                        label: treatment.applicationMethod,
                        colorScheme: colorScheme,
                      ),
                    if (treatment.timing.isNotEmpty)
                      _DetailChip(
                        icon: Icons.schedule,
                        label: treatment.timing,
                        colorScheme: colorScheme,
                      ),
                    if (treatment.estimatedCostPerHectare > 0)
                      _DetailChip(
                        icon: Icons.attach_money,
                        label:
                            '\$${treatment.estimatedCostPerHectare.toStringAsFixed(0)}/ha',
                        colorScheme: colorScheme,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static Color _priorityColor(TreatmentPriority priority) {
    return switch (priority) {
      TreatmentPriority.low => Colors.blue,
      TreatmentPriority.medium => Colors.orange,
      TreatmentPriority.high => Colors.deepOrange,
      TreatmentPriority.critical => Colors.red,
    };
  }

  static Color _typeColor(TreatmentType type) {
    return switch (type) {
      TreatmentType.chemical => Colors.purple,
      TreatmentType.biological => Colors.green,
      TreatmentType.cultural => Colors.brown,
      TreatmentType.mechanical => Colors.blueGrey,
      TreatmentType.preventive => Colors.teal,
    };
  }

  static IconData _typeIcon(TreatmentType type) {
    return switch (type) {
      TreatmentType.chemical => Icons.science,
      TreatmentType.biological => Icons.eco,
      TreatmentType.cultural => Icons.agriculture,
      TreatmentType.mechanical => Icons.build,
      TreatmentType.preventive => Icons.shield,
    };
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({
    required this.icon,
    required this.label,
    required this.colorScheme,
  });

  final IconData icon;
  final String label;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
