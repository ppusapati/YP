import 'package:flutter/material.dart';

import '../../domain/entities/diagnosis_entity.dart';

/// Visual indicator showing disease severity level with color-coded bars.
class SeverityIndicator extends StatelessWidget {
  const SeverityIndicator({
    super.key,
    required this.severity,
    this.compact = false,
  });

  final DiagnosisSeverity severity;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _CompactIndicator(severity: severity);
    }
    return _FullIndicator(severity: severity);
  }
}

class _CompactIndicator extends StatelessWidget {
  const _CompactIndicator({required this.severity});

  final DiagnosisSeverity severity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _severityColor(severity);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            severity.displayName,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _FullIndicator extends StatelessWidget {
  const _FullIndicator({required this.severity});

  final DiagnosisSeverity severity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final activeColor = _severityColor(severity);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: activeColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: activeColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _severityIcon(severity),
                color: activeColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Severity: ${severity.displayName}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: activeColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: DiagnosisSeverity.values.map((level) {
              final isActive = level.index <= severity.index;
              final isCurrent = level == severity;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    children: [
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: isActive
                              ? _severityColor(level)
                              : colorScheme.surfaceContainerHighest,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        level.displayName,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isCurrent
                              ? activeColor
                              : colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.5),
                          fontWeight:
                              isCurrent ? FontWeight.w700 : FontWeight.normal,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

Color _severityColor(DiagnosisSeverity severity) {
  return switch (severity) {
    DiagnosisSeverity.healthy => Colors.green,
    DiagnosisSeverity.mild => Colors.amber.shade700,
    DiagnosisSeverity.moderate => Colors.orange,
    DiagnosisSeverity.severe => Colors.red,
  };
}

IconData _severityIcon(DiagnosisSeverity severity) {
  return switch (severity) {
    DiagnosisSeverity.healthy => Icons.check_circle,
    DiagnosisSeverity.mild => Icons.info,
    DiagnosisSeverity.moderate => Icons.warning_amber,
    DiagnosisSeverity.severe => Icons.error,
  };
}
