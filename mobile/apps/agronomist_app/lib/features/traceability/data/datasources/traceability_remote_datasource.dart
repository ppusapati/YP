import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_network/flutter_network.dart';
import 'package:logging/logging.dart';

import '../models/trace_record_model.dart';

abstract class TraceabilityRemoteDataSource {
  Future<List<TraceRecordModel>> getTraceRecords({String? fieldId, String? batchNumber});
  Future<TraceRecordModel> getTraceRecordById(String id);
  Future<TraceRecordModel> createTraceRecord(TraceRecordModel record);
}

class TraceabilityRemoteDataSourceImpl implements TraceabilityRemoteDataSource {
  final ConnectClient _client;
  final _log = Logger('TraceabilityRemoteDataSource');

  TraceabilityRemoteDataSourceImpl(this._client);

  Future<Map<String, dynamic>> _post(
      String method, Map<String, dynamic> body) async {
    final path = '/agriculture.traceability.v1.TraceabilityService/$method';
    _log.fine('POST $path');

    final response = await _client.unary(
      path,
      body: Uint8List.fromList(utf8.encode(jsonEncode(body))),
      headers: {'Content-Type': 'application/json'},
    );

    if (!response.isSuccess) {
      throw TraceabilityRemoteException(
        'RPC call TraceabilityService/$method failed',
        statusCode: response.statusCode,
      );
    }

    return jsonDecode(utf8.decode(response.body)) as Map<String, dynamic>;
  }

  @override
  Future<List<TraceRecordModel>> getTraceRecords({
    String? fieldId,
    String? batchNumber,
  }) async {
    final body = <String, dynamic>{};
    if (fieldId != null) body['field_id'] = fieldId;
    if (batchNumber != null) body['batch_number'] = batchNumber;
    final data = await _post('ListRecords', body);
    final list = data['records'] as List<dynamic>? ?? [];
    return list
        .map((e) => TraceRecordModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<TraceRecordModel> getTraceRecordById(String id) async {
    final data = await _post('GetRecord', {'id': id});
    return TraceRecordModel.fromJson(data['record'] as Map<String, dynamic>);
  }

  @override
  Future<TraceRecordModel> createTraceRecord(TraceRecordModel record) async {
    final data = await _post('CreateRecord', {'record': record.toJson()});
    return TraceRecordModel.fromJson(data['record'] as Map<String, dynamic>);
  }
}

class TraceabilityRemoteException implements Exception {
  final String message;
  final int? statusCode;
  const TraceabilityRemoteException(this.message, {this.statusCode});
  @override
  String toString() =>
      'TraceabilityRemoteException($message, statusCode: $statusCode)';
}
