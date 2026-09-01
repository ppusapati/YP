import 'package:flutter_network/flutter_network.dart';
import 'package:flutter_proto/src/generated/traceability.pb.dart'
    as traceability_pb;
import 'package:protobuf/protobuf.dart' as $pb;

import '../models/trace_record_model.dart';

abstract class TraceabilityRemoteDataSource {
  Future<List<TraceRecordModel>> getTraceRecords({String? fieldId, String? batchNumber});
  Future<TraceRecordModel> getTraceRecordById(String id);
  Future<TraceRecordModel> createTraceRecord(TraceRecordModel record);
}

class TraceabilityRemoteDataSourceImpl implements TraceabilityRemoteDataSource {
  final ConnectClient _client;

  static const _basePath = '/agriculture.traceability.v1.TraceabilityService';

  TraceabilityRemoteDataSourceImpl(this._client);

  Future<ConnectResponse> _call(
      String method, $pb.GeneratedMessage request) async {
    final response = await _client.unary(
      '$_basePath/$method',
      body: request.writeToBuffer(),
    );
    if (!response.isSuccess) {
      throw TraceabilityRemoteException(
        'RPC call TraceabilityService/$method failed',
        statusCode: response.statusCode,
      );
    }
    return response;
  }

  @override
  Future<List<TraceRecordModel>> getTraceRecords({
    String? fieldId,
    String? batchNumber,
  }) async {
    // ListRecordsRequest does not have fieldId or batchNumber fields directly.
    // Use the search field for batch number filtering when provided.
    final request = traceability_pb.ListRecordsRequest(
      search: batchNumber,
    );
    final response = await _call('ListRecords', request);
    final pbResponse =
        traceability_pb.ListRecordsResponse.fromBuffer(response.body);
    return pbResponse.records.map(_recordFromProto).toList();
  }

  @override
  Future<TraceRecordModel> getTraceRecordById(String id) async {
    final request = traceability_pb.GetRecordRequest(id: id);
    final response = await _call('GetRecord', request);
    final pbResponse =
        traceability_pb.GetRecordResponse.fromBuffer(response.body);
    return _recordFromProto(pbResponse.record);
  }

  @override
  Future<TraceRecordModel> createTraceRecord(TraceRecordModel record) async {
    final request = traceability_pb.CreateRecordRequest(
      farmId: '',
      fieldId: record.fieldId,
      batchNumber: record.batchNumber,
      productType: record.cropName,
    );
    if (record.metadata.isNotEmpty) {
      request.metadata.addAll(record.metadata);
    }
    final response = await _call('CreateRecord', request);
    final pbResponse =
        traceability_pb.CreateRecordResponse.fromBuffer(response.body);
    return _recordFromProto(pbResponse.record);
  }

  /// Converts a protobuf [traceability_pb.TraceabilityRecord] to [TraceRecordModel].
  static TraceRecordModel _recordFromProto(
      traceability_pb.TraceabilityRecord pb) {
    final eventDate = pb.hasPlantingDate()
        ? DateTime.fromMillisecondsSinceEpoch(
            pb.plantingDate.seconds.toInt() * 1000)
        : DateTime.now();
    final createdAt = pb.hasCreatedAt()
        ? DateTime.fromMillisecondsSinceEpoch(
            pb.createdAt.seconds.toInt() * 1000)
        : DateTime.now();
    return TraceRecordModel(
      id: pb.id,
      fieldId: pb.fieldId,
      cropName: pb.productType,
      batchNumber: pb.batchNumber,
      eventType: pb.supplyChainEvents.isNotEmpty
          ? pb.supplyChainEvents.first.eventType.name
          : 'other',
      description: pb.originRegion,
      operatorName: '',
      metadata: Map<String, String>.from(pb.metadata),
      eventDate: eventDate,
      createdAt: createdAt,
    );
  }
}

/// Exception thrown when a remote traceability API call fails.
class TraceabilityRemoteException implements Exception {
  final String message;
  final int? statusCode;
  const TraceabilityRemoteException(this.message, {this.statusCode});
  @override
  String toString() =>
      'TraceabilityRemoteException($message, statusCode: $statusCode)';
}
