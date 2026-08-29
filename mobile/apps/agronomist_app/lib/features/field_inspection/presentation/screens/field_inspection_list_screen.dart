import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/field_inspection_bloc.dart';
import '../bloc/field_inspection_event.dart';
import '../bloc/field_inspection_state.dart';
import '../widgets/inspection_card.dart';

/// Screen listing all field inspections.
class FieldInspectionListScreen extends StatefulWidget {
  const FieldInspectionListScreen({super.key});

  @override
  State<FieldInspectionListScreen> createState() =>
      _FieldInspectionListScreenState();
}

class _FieldInspectionListScreenState extends State<FieldInspectionListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<FieldInspectionBloc>().add(const LoadInspections());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Field Inspections')),
      body: BlocBuilder<FieldInspectionBloc, FieldInspectionState>(
        builder: (context, state) {
          if (state is FieldInspectionLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is FieldInspectionError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline,
                      size: 48, color: theme.colorScheme.error),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => context
                        .read<FieldInspectionBloc>()
                        .add(const LoadInspections()),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is InspectionsLoaded) {
            if (state.inspections.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.assignment_outlined,
                        size: 80,
                        color: theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.4)),
                    const SizedBox(height: 24),
                    Text('No inspections yet',
                        style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text(
                      'Create your first field inspection\nto start tracking crop health.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<FieldInspectionBloc>()
                    .add(const LoadInspections());
              },
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: state.inspections.length,
                itemBuilder: (context, index) {
                  final inspection = state.inspections[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InspectionCard(
                      inspection: inspection,
                      onTap: () =>
                          context.push('/inspections/${inspection.id}'),
                    ),
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/inspections/create'),
        icon: const Icon(Icons.add),
        label: const Text('New Inspection'),
      ),
    );
  }
}
