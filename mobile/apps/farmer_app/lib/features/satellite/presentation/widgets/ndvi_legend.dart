import 'package:flutter/material.dart';

/// NDVI/EVI color legend showing the gradient from bare soil to dense vegetation.
class NdviLegend extends StatelessWidget {
  const NdviLegend({
    super.key,
    this.indexType = 'NDVI',
    this.onClose,
  });

  final String indexType;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      color: colorScheme.surface,
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$indexType Legend',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (onClose != null)
                  InkWell(
                    onTap: onClose,
                    borderRadius: BorderRadius.circular(12),
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 16,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFCE4A27), // Bare soil / water
                    Color(0xFFE8A83A), // Low vegetation
                    Color(0xFFF5E64C), // Sparse vegetation
                    Color(0xFF9ACD32), // Moderate vegetation
                    Color(0xFF228B22), // Dense vegetation
                    Color(0xFF006400), // Very dense vegetation
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '-0.2',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '0.0',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '0.5',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '1.0',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ..._legendItems.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: item.color,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.label,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  static const _legendItems = [
    _LegendItem(Color(0xFF006400), 'Dense vegetation (0.7-1.0)'),
    _LegendItem(Color(0xFF228B22), 'Moderate vegetation (0.5-0.7)'),
    _LegendItem(Color(0xFF9ACD32), 'Sparse vegetation (0.3-0.5)'),
    _LegendItem(Color(0xFFF5E64C), 'Low vegetation (0.1-0.3)'),
    _LegendItem(Color(0xFFCE4A27), 'Bare soil / water (<0.1)'),
  ];
}

class _LegendItem {
  final Color color;
  final String label;

  const _LegendItem(this.color, this.label);
}
