import 'package:equatable/equatable.dart';

enum TraceEventType {
  planting,
  fertilization,
  pesticide,
  irrigation,
  harvest,
  transport,
  storage,
  processing,
  qualityCheck,
  other,
}

class TraceRecordEntity extends Equatable {
  final String id;
  final String fieldId;
  final String cropName;
  final String batchNumber;
  final TraceEventType eventType;
  final String description;
  final String operatorName;
  final Map<String, String> metadata;
  final DateTime eventDate;
  final DateTime createdAt;

  const TraceRecordEntity({
    required this.id,
    required this.fieldId,
    required this.cropName,
    required this.batchNumber,
    required this.eventType,
    required this.description,
    required this.operatorName,
    this.metadata = const {},
    required this.eventDate,
    required this.createdAt,
  });

  String get eventTypeLabel {
    switch (eventType) {
      case TraceEventType.planting:
        return 'Planting';
      case TraceEventType.fertilization:
        return 'Fertilization';
      case TraceEventType.pesticide:
        return 'Pesticide Application';
      case TraceEventType.irrigation:
        return 'Irrigation';
      case TraceEventType.harvest:
        return 'Harvest';
      case TraceEventType.transport:
        return 'Transport';
      case TraceEventType.storage:
        return 'Storage';
      case TraceEventType.processing:
        return 'Processing';
      case TraceEventType.qualityCheck:
        return 'Quality Check';
      case TraceEventType.other:
        return 'Other';
    }
  }

  @override
  List<Object?> get props => [
        id, fieldId, cropName, batchNumber, eventType,
        description, operatorName, metadata, eventDate, createdAt,
      ];
}
