import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/traceability_bloc.dart';
import '../bloc/traceability_event.dart';
import '../bloc/traceability_state.dart';

class RecordDetailScreen extends StatefulWidget {
  const RecordDetailScreen({super.key, required this.recordId});
  final String recordId;

  @override
  State<RecordDetailScreen> createState() => _RecordDetailScreenState();
}

class _RecordDetailScreenState extends State<RecordDetailScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<TraceabilityBloc>()
        .add(LoadTraceRecordById(id: widget.recordId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Trace Record')),
      body: BlocBuilder<TraceabilityBloc, TraceabilityState>(
        builder: (context, state) {
          if (state is TraceabilityLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TraceabilityError) {
            return Center(child: Text(state.message));
          }
          if (state is TraceRecordLoaded) {
            final record = state.record;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header card
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: colorScheme.outlineVariant),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(Icons.qr_code_scanner,
                                    color: colorScheme.onPrimaryContainer,
                                    size: 32),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(record.eventTypeLabel,
                                        style: theme.textTheme.headlineSmall),
                                    const SizedBox(height: 4),
                                    Text(record.cropName,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                                color: colorScheme
                                                    .onSurfaceVariant)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Details section
                  Text('Details',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  _DetailRow(
                      label: 'Batch Number', value: record.batchNumber),
                  _DetailRow(
                      label: 'Operator', value: record.operatorName),
                  _DetailRow(
                      label: 'Event Date',
                      value: DateFormat.yMMMMd().format(record.eventDate)),
                  _DetailRow(
                      label: 'Recorded',
                      value: DateFormat.yMMMMd().format(record.createdAt)),
                  if (record.description.isNotEmpty)
                    _DetailRow(
                        label: 'Description', value: record.description),

                  if (record.metadata.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text('Metadata',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    ...record.metadata.entries.map(
                      (entry) =>
                          _DetailRow(label: entry.key, value: entry.value),
                    ),
                  ],
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                )),
          ),
          Expanded(
            child: Text(value, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
