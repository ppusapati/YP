import 'package:flutter/material.dart';
import 'package:flutter_ui_core/flutter_ui_core.dart'
    show AnalysedImage, ExplanationSection;

import '../../domain/entities/diagnosis_entity.dart';
import '../widgets/confidence_badge.dart';
import '../widgets/severity_indicator.dart';
import '../widgets/treatment_card.dart';

/// Screen showing diagnosis results: disease info, confidence, treatments.
class DiagnosisResultScreen extends StatelessWidget {
  const DiagnosisResultScreen({super.key, required this.diagnosis});

  final Diagnosis diagnosis;

  static const String routePath = '/diagnosis/result';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnosis Result'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image preview.
            if (diagnosis.imagePath.isNotEmpty)
              SizedBox(
                height: 240,
                child: AnalysedImage(imagePath: diagnosis.imagePath),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Disease name and confidence.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (diagnosis.plantSpecies.isNotEmpty) ...[
                              Text(
                                diagnosis.plantSpecies,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                            ],
                            Text(
                              diagnosis.diseaseName,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (diagnosis.diseaseType.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                diagnosis.diseaseType,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      ConfidenceBadge(confidence: diagnosis.confidence),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Severity indicator.
                  SeverityIndicator(severity: diagnosis.severity),
                  const SizedBox(height: 20),
                  // Description.
                  Text(
                    'Description',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    diagnosis.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  // Quick recommendations.
                  if (diagnosis.recommendations.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Quick Actions',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...diagnosis.recommendations.map(
                      (rec) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.check_circle_outline,
                                size: 18, color: colorScheme.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                rec,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  // Why the model answered this way.
                  const SizedBox(height: 24),
                  ExplanationSection(
                    explanations: diagnosis.explanations,
                    imagePath: diagnosis.imagePath,
                  ),
                  // Treatment recommendations.
                  if (diagnosis.treatments.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Treatment Recommendations',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...diagnosis.treatments.map(
                      (treatment) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TreatmentCard(treatment: treatment),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
