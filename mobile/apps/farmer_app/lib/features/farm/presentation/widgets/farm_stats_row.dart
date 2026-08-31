import 'package:flutter/material.dart';

import '../../domain/entities/farm_entity.dart';

/// A row displaying key farm statistics (total area, fields, mapped area).
class FarmStatsRow extends StatelessWidget {
  const FarmStatsRow({super.key, required this.farm});

  final FarmEntity farm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            label: 'Total Area',
            value: '${farm.totalAreaHectares.toStringAsFixed(1)} ha',
            icon: Icons.landscape,
            color: colorScheme.primary,
          ),
          _Divider(color: colorScheme.outlineVariant),
          _StatItem(
            label: 'Fields',
            value: '${farm.fields.length}',
            icon: Icons.grid_view,
            color: Colors.green,
          ),
          _Divider(color: colorScheme.outlineVariant),
          _StatItem(
            label: 'Active',
            value: '${farm.activeFieldCount}',
            icon: Icons.check_circle,
            color: Colors.teal,
          ),
          _Divider(color: colorScheme.outlineVariant),
          _StatItem(
            label: 'Mapped',
            value: '${farm.mappedAreaHectares.toStringAsFixed(1)} ha',
            icon: Icons.map,
            color: Colors.orange,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 6),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: color,
    );
  }
}
