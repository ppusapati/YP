import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ui_core/flutter_ui_core.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/produce_record_entity.dart';

/// Displays a certification badge with validity status.
class CertificationBadge extends StatelessWidget {
  const CertificationBadge({
    super.key,
    required this.certification,
  });

  final Certification certification;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM yyyy');
    final isValid = certification.isValid;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isValid
            ? AppColors.successContainer.withValues(alpha: 0.5)
            : AppColors.errorContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isValid
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Logo or fallback icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: certification.logoUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: CachedNetworkImage(
                      imageUrl: certification.logoUrl!,
                      fit: BoxFit.contain,
                      placeholder: (_, __) => const Icon(
                        Icons.verified_outlined,
                        color: AppColors.success,
                      ),
                      errorWidget: (_, __, ___) => const Icon(
                        Icons.verified_outlined,
                        color: AppColors.success,
                      ),
                    ),
                  )
                : Icon(
                    Icons.verified_outlined,
                    color: isValid ? AppColors.success : AppColors.error,
                    size: 24,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  certification.name,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  'Issued by ${certification.issuer}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (certification.certificateNumber != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '#${certification.certificateNumber}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
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
                  color: isValid ? AppColors.success : AppColors.error,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isValid ? 'Valid' : 'Expired',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isValid ? 'Until ${dateFormat.format(certification.validUntil)}' : 'Expired ${dateFormat.format(certification.validUntil)}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
