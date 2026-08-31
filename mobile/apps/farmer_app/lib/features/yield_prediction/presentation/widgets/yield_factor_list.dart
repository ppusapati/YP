import 'package:flutter/material.dart';

import '../../domain/entities/yield_factor_entity.dart';

class YieldFactorList extends StatelessWidget {
  const YieldFactorList({
    super.key,
    required this.factors,
  });

  final List<YieldFactor> factors;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (factors.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'No factor data available',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final sortedFactors = List<YieldFactor>.from(factors)
      ..sort((a, b) => b.impact.abs().compareTo(a.impact.abs()));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sortedFactors.map((factor) => _FactorTile(factor: factor)).toList(),
    );
  }
}

class _FactorTile extends StatelessWidget {
  const _FactorTile({required this.factor});

  final YieldFactor factor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isPositive = factor.isPositive;
    final color = isPositive ? Colors.green : Colors.red;
    final barWidth = factor.impact.abs().clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  factor.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 14,
                    color: color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    factor.impactPercentage,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: barWidth,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 44,
                child: Text(
                  factor.value.toStringAsFixed(1),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFeatures: [const FontFeature.tabularFigures()],
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
