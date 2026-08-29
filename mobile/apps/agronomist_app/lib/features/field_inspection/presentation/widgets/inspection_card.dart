import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/inspection_entity.dart';
import 'health_score_indicator.dart';

/// A card displaying an inspection summary.
class InspectionCard extends StatelessWidget {
  const InspectionCard({
    super.key,
    required this.inspection,
    this.onTap,
  });

  final InspectionEntity inspection;
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
              HealthScoreIndicator(score: inspection.healthScore),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Field ${inspection.fieldId}',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat.yMMMd().format(inspection.date),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (inspection.issues.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${inspection.issues.length} issue(s)',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.error,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Chip(
                label: Text(
                  inspection.isDraft ? 'Draft' : 'Submitted',
                  style: theme.textTheme.labelSmall,
                ),
                backgroundColor: inspection.isDraft
                    ? colorScheme.surfaceContainerHighest
                    : colorScheme.primaryContainer,
                side: BorderSide.none,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
