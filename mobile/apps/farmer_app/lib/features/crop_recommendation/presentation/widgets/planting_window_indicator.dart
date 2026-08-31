import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A visual timeline showing the planting window for a crop recommendation.
class PlantingWindowIndicator extends StatelessWidget {
  const PlantingWindowIndicator({
    super.key,
    required this.start,
    required this.end,
  });

  final DateTime start;
  final DateTime end;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d');
    final now = DateTime.now();

    final totalDays = end.difference(start).inDays;
    final isActive = now.isAfter(start) && now.isBefore(end);
    final isPast = now.isAfter(end);
    final isFuture = now.isBefore(start);

    double progressFraction = 0.0;
    if (isActive && totalDays > 0) {
      progressFraction =
          now.difference(start).inDays / totalDays;
    } else if (isPast) {
      progressFraction = 1.0;
    }

    final activeColor = isActive
        ? theme.colorScheme.primary
        : isPast
            ? theme.colorScheme.outline
            : theme.colorScheme.tertiary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              'Planting Window',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            if (isActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Active',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else if (isFuture)
              Text(
                'In ${start.difference(now).inDays} days',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.tertiary,
                ),
              )
            else
              Text(
                'Ended',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 28,
              decoration: BoxDecoration(
                color: activeColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: activeColor.withValues(alpha: 0.2),
                ),
              ),
            ),
            if (isActive)
              FractionallySizedBox(
                widthFactor: progressFraction.clamp(0.0, 1.0),
                child: Container(
                  height: 28,
                  decoration: BoxDecoration(
                    color: activeColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            SizedBox(
              height: 28,
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  Text(
                    dateFormat.format(start),
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Container(
                        height: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        color: activeColor.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  Text(
                    dateFormat.format(end),
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            if (isActive)
              Positioned(
                left: (MediaQuery.of(context).size.width - 80) *
                    progressFraction.clamp(0.0, 1.0),
                top: 0,
                bottom: 0,
                child: Container(
                  width: 2,
                  color: activeColor,
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '$totalDays days window',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
