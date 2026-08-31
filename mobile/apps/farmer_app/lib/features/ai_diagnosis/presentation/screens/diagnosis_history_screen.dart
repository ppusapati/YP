import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/diagnosis_entity.dart';
import '../bloc/diagnosis_bloc.dart';
import '../bloc/diagnosis_event.dart';
import '../bloc/diagnosis_state.dart';
import '../widgets/confidence_badge.dart';
import '../widgets/severity_indicator.dart';
import 'diagnosis_result_screen.dart';

/// Screen listing past AI diagnoses with date and results.
class DiagnosisHistoryScreen extends StatefulWidget {
  const DiagnosisHistoryScreen({super.key, this.fieldId});

  final String? fieldId;

  static const String routePath = '/diagnosis/history';

  @override
  State<DiagnosisHistoryScreen> createState() => _DiagnosisHistoryScreenState();
}

class _DiagnosisHistoryScreenState extends State<DiagnosisHistoryScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<DiagnosisBloc>()
        .add(LoadDiagnosisHistory(fieldId: widget.fieldId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnosis History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context
                  .read<DiagnosisBloc>()
                  .add(LoadDiagnosisHistory(fieldId: widget.fieldId));
            },
          ),
        ],
      ),
      body: BlocBuilder<DiagnosisBloc, DiagnosisState>(
        builder: (context, state) {
          if (state is DiagnosisLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DiagnosisError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline,
                      size: 48, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      context.read<DiagnosisBloc>().add(
                            LoadDiagnosisHistory(fieldId: widget.fieldId),
                          );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is DiagnosisHistoryLoaded) {
            if (state.diagnoses.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.history,
                      size: 64,
                      color: colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No diagnoses yet',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Take a photo of a plant to get started',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<DiagnosisBloc>().add(
                      LoadDiagnosisHistory(fieldId: widget.fieldId),
                    );
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.diagnoses.length,
                itemBuilder: (context, index) {
                  final diagnosis = state.diagnoses[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _DiagnosisHistoryCard(
                      diagnosis: diagnosis,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => DiagnosisResultScreen(
                              diagnosis: diagnosis,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _DiagnosisHistoryCard extends StatelessWidget {
  const _DiagnosisHistoryCard({
    required this.diagnosis,
    this.onTap,
  });

  final Diagnosis diagnosis;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dateFormat = DateFormat('MMM d, y - h:mm a');

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Thumbnail.
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: colorScheme.surfaceContainerLow,
                ),
                clipBehavior: Clip.antiAlias,
                child: diagnosis.imagePath.isNotEmpty
                    ? Image.file(
                        File(diagnosis.imagePath),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.image,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      )
                    : Icon(
                        Icons.biotech,
                        color: colorScheme.onSurfaceVariant,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            diagnosis.diseaseName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        ConfidenceBadge(
                          confidence: diagnosis.confidence,
                          size: ConfidenceBadgeSize.small,
                        ),
                      ],
                    ),
                    if (diagnosis.plantSpecies.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        diagnosis.plantSpecies,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        SeverityIndicator(
                          severity: diagnosis.severity,
                          compact: true,
                        ),
                        const Spacer(),
                        Text(
                          dateFormat.format(diagnosis.createdAt),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
