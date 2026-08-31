import '../../domain/entities/trace_record_entity.dart';

class TraceRecordModel {
  final String id;
  final String fieldId;
  final String cropName;
  final String batchNumber;
  final String eventType;
  final String description;
  final String operatorName;
  final Map<String, String> metadata;
  final DateTime eventDate;
  final DateTime createdAt;

  const TraceRecordModel({
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

  factory TraceRecordModel.fromJson(Map<String, dynamic> json) {
    final rawMeta = json['metadata'] as Map<String, dynamic>? ?? {};
    return TraceRecordModel(
      id: json['id'] as String? ?? '',
      fieldId: json['field_id'] as String? ?? '',
      cropName: json['crop_name'] as String? ?? '',
      batchNumber: json['batch_number'] as String? ?? '',
      eventType: json['event_type'] as String? ?? 'other',
      description: json['description'] as String? ?? '',
      operatorName: json['operator_name'] as String? ?? '',
      metadata: rawMeta.map((k, v) => MapEntry(k, v.toString())),
      eventDate: json['event_date'] != null
          ? DateTime.parse(json['event_date'] as String)
          : DateTime.now(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'field_id': fieldId,
        'crop_name': cropName,
        'batch_number': batchNumber,
        'event_type': eventType,
        'description': description,
        'operator_name': operatorName,
        'metadata': metadata,
        'event_date': eventDate.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };

  TraceRecordEntity toEntity() => TraceRecordEntity(
        id: id,
        fieldId: fieldId,
        cropName: cropName,
        batchNumber: batchNumber,
        eventType: _parseEventType(eventType),
        description: description,
        operatorName: operatorName,
        metadata: metadata,
        eventDate: eventDate,
        createdAt: createdAt,
      );

  factory TraceRecordModel.fromEntity(TraceRecordEntity entity) =>
      TraceRecordModel(
        id: entity.id,
        fieldId: entity.fieldId,
        cropName: entity.cropName,
        batchNumber: entity.batchNumber,
        eventType: entity.eventType.name,
        description: entity.description,
        operatorName: entity.operatorName,
        metadata: entity.metadata,
        eventDate: entity.eventDate,
        createdAt: entity.createdAt,
      );

  static TraceEventType _parseEventType(String value) {
    for (final t in TraceEventType.values) {
      if (t.name == value) return t;
    }
    return TraceEventType.other;
  }
}
