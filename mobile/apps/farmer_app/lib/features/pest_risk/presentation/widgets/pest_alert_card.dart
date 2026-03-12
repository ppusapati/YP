import 'package:flutter/material.dart';
import 'package:flutter_ui_core/flutter_ui_core.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/pest_risk_entity.dart';

/// A summary card for a single [PestAlert].
class PestAlertCard extends StatelessWidget {
  const PestAlertCard({
    super.key,
    required this.alert,
    this.onTap,
  });

  final PestAlert alert;
  final VoidCallback? onTap;

  Color get _riskColor => switch (alert.riskLevel) {
        RiskLevel.low => AppColors.pestLow,
        RiskLevel.moderate => AppColors.pestModerate,
        RiskLevel.high => AppColors.pestHigh,
        RiskLevel.critical => AppColors.pestCritical,
      };

  IconData get _riskIcon => switch (alert.riskLevel) {
        RiskLevel.low => Icons.info_outline,
        RiskLevel.moderate => Icons.warning_amber_outlined,
        RiskLevel.high => Icons.warning_outlined,
        RiskLevel.critical => Icons.dangerous_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, yyyy h:mm a');

    return Card(
      elevation: alert.isRead ? 0 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: alert.isRead
              ? theme.colorScheme.outlineVariant
              : _riskColor.withValues(alpha: 0.5),
          width: alert.isRead ? 0.5 : 1.5,
        ),
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
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _riskColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(_riskIcon, size: 20, color: _riskColor),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight:
                                alert.isRead ? FontWeight.w500 : FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          alert.pestType,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _riskColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          alert.riskLevel.label,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: _riskColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (!alert.isRead) ...[
                        const SizedBox(height: 4),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                alert.message,
                style: theme.textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                dateFormat.format(alert.createdAt),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
