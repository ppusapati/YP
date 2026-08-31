import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/observation_entity.dart';

/// Summary card for a [FieldObservation] with thumbnail.
class ObservationCard extends StatelessWidget {
  const ObservationCard({
    super.key,
    required this.observation,
    this.onTap,
  });

  final FieldObservation observation;
  final VoidCallback? onTap;

  Color get _categoryColor => switch (observation.category) {
        ObservationCategory.pest => const Color(0xFFD32F2F),
        ObservationCategory.disease => const Color(0xFFE64A19),
        ObservationCategory.weed => const Color(0xFF7B1FA2),
        ObservationCategory.growth => const Color(0xFF388E3C),
        ObservationCategory.soil => const Color(0xFF795548),
        ObservationCategory.water => const Color(0xFF0288D1),
        ObservationCategory.weather => const Color(0xFF455A64),
        ObservationCategory.wildlife => const Color(0xFF689F38),
        ObservationCategory.equipment => const Color(0xFF616161),
        ObservationCategory.other => const Color(0xFF9E9E9E),
      };

  IconData get _categoryIcon => switch (observation.category) {
        ObservationCategory.pest => Icons.bug_report_outlined,
        ObservationCategory.disease => Icons.coronavirus_outlined,
        ObservationCategory.weed => Icons.grass_outlined,
        ObservationCategory.growth => Icons.trending_up_outlined,
        ObservationCategory.soil => Icons.landscape_outlined,
        ObservationCategory.water => Icons.water_drop_outlined,
        ObservationCategory.weather => Icons.cloud_outlined,
        ObservationCategory.wildlife => Icons.pets_outlined,
        ObservationCategory.equipment => Icons.build_outlined,
        ObservationCategory.other => Icons.note_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, yyyy h:mm a');

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            // Thumbnail
            SizedBox(
              width: 90,
              height: 90,
              child: observation.photos.isNotEmpty
                  ? _buildThumbnail(observation.photos.first)
                  : Container(
                      color: _categoryColor.withValues(alpha: 0.1),
                      child: Icon(
                        _categoryIcon,
                        size: 36,
                        color: _categoryColor,
                      ),
                    ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _categoryColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_categoryIcon,
                                  size: 12, color: _categoryColor),
                              const SizedBox(width: 4),
                              Text(
                                observation.category.label,
                                style: TextStyle(
                                  color: _categoryColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        if (observation.photos.isNotEmpty)
                          Row(
                            children: [
                              Icon(Icons.photo_outlined,
                                  size: 14,
                                  color: theme.colorScheme.onSurfaceVariant),
                              const SizedBox(width: 2),
                              Text(
                                '${observation.photos.length}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      observation.notes.isNotEmpty
                          ? observation.notes
                          : 'No notes',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: observation.notes.isNotEmpty
                            ? null
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateFormat.format(observation.timestamp),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(String photoPath) {
    if (photoPath.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: photoPath,
        fit: BoxFit.cover,
        placeholder: (_, __) =>
            const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        errorWidget: (_, __, ___) => const Icon(Icons.broken_image_outlined),
      );
    }
    return Image.file(File(photoPath), fit: BoxFit.cover);
  }
}
