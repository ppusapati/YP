import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Trend direction for [StatCard].
enum StatTrend {
  up,
  down,
  flat;

  IconData get icon => switch (this) {
        StatTrend.up => Icons.trending_up_rounded,
        StatTrend.down => Icons.trending_down_rounded,
        StatTrend.flat => Icons.trending_flat_rounded,
      };

  Color get color => switch (this) {
        StatTrend.up => AppColors.success,
        StatTrend.down => AppColors.error,
        StatTrend.flat => AppColors.outline,
      };
}

/// Visual variant of [StatCard].
enum StatCardVariant { compact, expanded }

/// A reusable stat card showing a title, value, optional unit, icon, and trend.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.unit,
    this.icon,
    this.iconColor,
    this.trend,
    this.trendLabel,
    this.variant = StatCardVariant.compact,
    this.onTap,
  });

  final String title;
  final String value;
  final String? unit;
  final IconData? icon;
  final Color? iconColor;
  final StatTrend? trend;
  final String? trendLabel;
  final StatCardVariant variant;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: variant == StatCardVariant.compact
              ? const EdgeInsets.all(14)
              : const EdgeInsets.all(20),
          child: variant == StatCardVariant.compact
              ? _buildCompact(colorScheme)
              : _buildExpanded(colorScheme),
        ),
      ),
    );
  }

  Widget _buildCompact(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: iconColor ?? colorScheme.primary),
              const SizedBox(width: 6),
            ],
            Expanded(
              child: Text(
                title,
                style: AppTypography.labelMedium.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(value, style: AppTypography.statValue.copyWith(
              color: colorScheme.onSurface,
            )),
            if (unit != null) ...[
              const SizedBox(width: 4),
              Text(unit!, style: AppTypography.unitLabel.copyWith(
                color: colorScheme.onSurfaceVariant,
              )),
            ],
          ],
        ),
        if (trend != null) ...[
          const SizedBox(height: 6),
          _TrendRow(trend: trend!, label: trendLabel),
        ],
      ],
    );
  }

  Widget _buildExpanded(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            if (icon != null)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (iconColor ?? colorScheme.primary).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 24, color: iconColor ?? colorScheme.primary),
              ),
            if (icon != null) const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: AppTypography.titleSmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            if (trend != null) _TrendRow(trend: trend!, label: trendLabel),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(value, style: AppTypography.metricValue.copyWith(
              color: colorScheme.onSurface,
            )),
            if (unit != null) ...[
              const SizedBox(width: 6),
              Text(unit!, style: AppTypography.unitLabel.copyWith(
                color: colorScheme.onSurfaceVariant,
              )),
            ],
          ],
        ),
      ],
    );
  }
}

class _TrendRow extends StatelessWidget {
  const _TrendRow({required this.trend, this.label});

  final StatTrend trend;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(trend.icon, size: 16, color: trend.color),
        if (label != null) ...[
          const SizedBox(width: 4),
          Text(
            label!,
            style: AppTypography.labelSmall.copyWith(color: trend.color),
          ),
        ],
      ],
    );
  }
}
