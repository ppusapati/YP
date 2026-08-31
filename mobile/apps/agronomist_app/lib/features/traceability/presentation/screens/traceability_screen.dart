import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/trace_record_entity.dart';
import '../bloc/traceability_bloc.dart';
import '../bloc/traceability_event.dart';
import '../bloc/traceability_state.dart';

class TraceabilityScreen extends StatefulWidget {
  const TraceabilityScreen({super.key});

  @override
  State<TraceabilityScreen> createState() => _TraceabilityScreenState();
}

class _TraceabilityScreenState extends State<TraceabilityScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TraceabilityBloc>().add(const LoadTraceRecords());
  }

  IconData _iconForEventType(TraceEventType type) {
    switch (type) {
      case TraceEventType.planting:
        return Icons.grass;
      case TraceEventType.fertilization:
        return Icons.science;
      case TraceEventType.pesticide:
        return Icons.bug_report;
      case TraceEventType.irrigation:
        return Icons.water_drop;
      case TraceEventType.harvest:
        return Icons.agriculture;
      case TraceEventType.transport:
        return Icons.local_shipping;
      case TraceEventType.storage:
        return Icons.warehouse;
      case TraceEventType.processing:
        return Icons.precision_manufacturing;
      case TraceEventType.qualityCheck:
        return Icons.verified;
      case TraceEventType.other:
        return Icons.more_horiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Traceability'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<TraceabilityBloc>().add(const LoadTraceRecords());
            },
          ),
        ],
      ),
      body: BlocBuilder<TraceabilityBloc, TraceabilityState>(
        builder: (context, state) {
          if (state is TraceabilityLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TraceabilityError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text('Failed to load records',
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(state.message,
                      style: theme.textTheme.bodySmall,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () {
                      context
                          .read<TraceabilityBloc>()
                          .add(const LoadTraceRecords());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is TraceRecordsLoaded) {
            if (state.records.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.qr_code_scanner,
                        size: 80,
                        color:
                            colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
                    const SizedBox(height: 24),
                    Text('No traceability records',
                        style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text(
                      'Records for crop lifecycle events\nwill appear here.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<TraceabilityBloc>()
                    .add(const LoadTraceRecords());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.records.length,
                itemBuilder: (context, index) {
                  final record = state.records[index];
                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: colorScheme.primaryContainer,
                        child: Icon(_iconForEventType(record.eventType),
                            color: colorScheme.onPrimaryContainer, size: 20),
                      ),
                      title: Text(record.eventTypeLabel),
                      subtitle: Text(
                        '${record.cropName} - Batch ${record.batchNumber}\n'
                        '${DateFormat.yMMMd().format(record.eventDate)}',
                      ),
                      isThreeLine: true,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/traceability/${record.id}'),
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
