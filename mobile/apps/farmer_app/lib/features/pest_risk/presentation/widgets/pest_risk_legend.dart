import 'package:flutter/material.dart';
import 'package:flutter_ui_core/flutter_ui_core.dart';

import '../../domain/entities/pest_risk_entity.dart';

/// Displays a color-coded legend for pest risk levels.
class PestRiskLegend extends StatelessWidget {
  const PestRiskLegend({
    super.key,
    this.activeFilter,
    this.onFilterTap,
  });

  /// Currently active risk level filter, or null for "show all".
  final RiskLevel? activeFilter;

  /// Called when a legend item is tapped to toggle filter.
  final ValueChanged<RiskLevel?>? onFilterTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.legend_toggle, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
                Text('Risk Levels', style: theme.textTheme.labelLarge),
                const Spacer(),
                if (activeFilter != null)
                  GestureDetector(
                    onTap: () => onFilterTap?.call(null),
                    child: Text(
                      'Clear',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            ...RiskLevel.values.map(
              (level) => _LegendItem(
                level: level,
                isActive: activeFilter == null || activeFilter == level,
                onTap: () => onFilterTap?.call(
                  activeFilter == level ? null : level,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.level,
    required this.isActive,
    required this.onTap,
  });

  final RiskLevel level;
  final bool isActive;
  final VoidCallback onTap;

  Color get _color => switch (level) {
        RiskLevel.low => AppColors.pestLow,
        RiskLevel.moderate => AppColors.pestModerate,
        RiskLevel.high => AppColors.pestHigh,
        RiskLevel.critical => AppColors.pestCritical,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: isActive ? 1.0 : 0.35,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: _color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 8),
              Text(level.label, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
