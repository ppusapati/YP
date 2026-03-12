import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/produce_record_entity.dart';

/// A vertical timeline displaying treatment history for a produce batch.
class TreatmentTimeline extends StatelessWidget {
  const TreatmentTimeline({
    super.key,
    required this.treatments,
  });

  final List<Treatment> treatments;

  Color _typeColor(String type) => switch (type.toLowerCase()) {
        'pesticide' => const Color(0xFFD32F2F),
        'herbicide' => const Color(0xFF7B1FA2),
        'fertilizer' => const Color(0xFF388E3C),
        'biological' => const Color(0xFF0288D1),
        'fungicide' => const Color(0xFFE64A19),
        _ => const Color(0xFF616161),
      };

  IconData _typeIcon(String type) => switch (type.toLowerCase()) {
        'pesticide' => Icons.bug_report_outlined,
        'herbicide' => Icons.grass_outlined,
        'fertilizer' => Icons.eco_outlined,
        'biological' => Icons.science_outlined,
        'fungicide' => Icons.coronavirus_outlined,
        _ => Icons.medication_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, yyyy');

    if (treatments.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(Icons.eco_outlined,
                size: 40, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              'No treatments recorded',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    // Sort by date descending.
    final sorted = List<Treatment>.from(treatments)
      ..sort((a, b) => b.date.compareTo(a.date));

    return Column(
      children: List.generate(sorted.length, (index) {
        final treatment = sorted[index];
        final isLast = index == sorted.length - 1;
        final color = _typeColor(treatment.type);

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline rail
              SizedBox(
                width: 40,
                child: Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: color, width: 2),
                      ),
                      child: Icon(_typeIcon(treatment.type),
                          size: 16, color: color),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: theme.colorScheme.outlineVariant,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                treatment.name,
                                style: theme.textTheme.titleSmall,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                treatment.type,
                                style: TextStyle(
                                  color: color,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.calendar_today_outlined,
                                size: 14,
                                color: theme.colorScheme.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text(
                              dateFormat.format(treatment.date),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        if (treatment.dosage != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.medication_outlined,
                                  size: 14,
                                  color: theme.colorScheme.onSurfaceVariant),
                              const SizedBox(width: 4),
                              Text(
                                'Dosage: ${treatment.dosage}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (treatment.applicator != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.person_outline,
                                  size: 14,
                                  color: theme.colorScheme.onSurfaceVariant),
                              const SizedBox(width: 4),
                              Text(
                                'Applied by: ${treatment.applicator}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (treatment.notes != null &&
                            treatment.notes!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            treatment.notes!,
                            style: theme.textTheme.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
