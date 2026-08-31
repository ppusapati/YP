import 'package:flutter/material.dart';

import '../../domain/entities/field_entity.dart';

/// A list tile displaying a field's summary information.
class FieldListTile extends StatelessWidget {
  const FieldListTile({
    super.key,
    required this.field,
    this.onTap,
    this.onDelete,
  });

  final FieldEntity field;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _statusColor(field.status).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            _cropIcon(field.cropType),
            color: _statusColor(field.status),
            size: 22,
          ),
        ),
        title: Text(
          field.name,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Row(
          children: [
            Text(
              '${field.areaHectares.toStringAsFixed(1)} ha',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (field.cropType != CropType.none) ...[
              const SizedBox(width: 8),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                field.cropType.displayName,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor(field.status).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                field.status.displayName,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: _statusColor(field.status),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (onDelete != null) ...[
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(Icons.delete_outline,
                    size: 20, color: colorScheme.error),
                onPressed: onDelete,
              ),
            ],
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  static Color _statusColor(FieldStatus status) {
    return switch (status) {
      FieldStatus.active => Colors.green,
      FieldStatus.fallow => Colors.orange,
      FieldStatus.planned => Colors.blue,
      FieldStatus.archived => Colors.grey,
    };
  }

  static IconData _cropIcon(CropType cropType) {
    return switch (cropType) {
      CropType.wheat => Icons.grass,
      CropType.corn => Icons.grass,
      CropType.soybean => Icons.eco,
      CropType.rice => Icons.water,
      CropType.cotton => Icons.cloud,
      CropType.sugarcane => Icons.park,
      CropType.barley => Icons.grass,
      CropType.sunflower => Icons.local_florist,
      CropType.potato => Icons.spa,
      CropType.tomato => Icons.spa,
      CropType.other => Icons.eco,
      CropType.none => Icons.grid_view,
    };
  }
}
