import 'package:flutter/material.dart';

/// Screen for crop performance metrics and historical yields.
class CropPerformanceScreen extends StatelessWidget {
  const CropPerformanceScreen({super.key, required this.fieldId});
  final String fieldId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Crop Performance')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bar_chart, size: 80,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: 24),
            Text('Performance Analytics', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Historical yield trends and crop performance\nmetrics for field $fieldId.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
