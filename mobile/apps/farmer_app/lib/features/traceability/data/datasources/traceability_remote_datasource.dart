import 'dart:convert';

import 'package:flutter_network/flutter_network.dart';
import 'package:logging/logging.dart';

import '../models/produce_record_model.dart';

/// Remote data source for traceability data via ConnectRPC.
abstract class TraceabilityRemoteDataSource {
  Future<ProduceRecordModel> scanQrCode(String qrData);
  Future<ProduceRecordModel> fetchProduceRecord(String recordId);
  Future<List<ProduceRecordModel>> fetchFarmHistory(String farmId);
}

class TraceabilityRemoteDataSourceImpl
    implements TraceabilityRemoteDataSource {
  TraceabilityRemoteDataSourceImpl({required ConnectClient client})
      : _client = client;

  final ConnectClient _client;
  static final _log = Logger('TraceabilityRemoteDataSource');

  static const _basePath =
      '/yieldpoint.traceability.v1.TraceabilityService';

  @override
  Future<ProduceRecordModel> scanQrCode(String qrData) async {
    try {
      final body = utf8.encode(jsonEncode({'qr_data': qrData}));
      final response = await _client.unary(
        '$_basePath/ScanQRCode',
        body: body as dynamic,
      );
      final data =
          jsonDecode(utf8.decode(response.body)) as Map<String, dynamic>;
      return ProduceRecordModel.fromJson(data);
    } on ConnectException catch (e) {
      _log.severe('Failed to scan QR code: $e');
      rethrow;
    }
  }

  @override
  Future<ProduceRecordModel> fetchProduceRecord(String recordId) async {
    try {
      final body = utf8.encode(jsonEncode({'record_id': recordId}));
      final response = await _client.unary(
        '$_basePath/GetProduceRecord',
        body: body as dynamic,
      );
      final data =
          jsonDecode(utf8.decode(response.body)) as Map<String, dynamic>;
      return ProduceRecordModel.fromJson(data);
    } on ConnectException catch (e) {
      _log.severe('Failed to fetch produce record $recordId: $e');
      rethrow;
    }
  }

  @override
  Future<List<ProduceRecordModel>> fetchFarmHistory(String farmId) async {
    try {
      final body = utf8.encode(jsonEncode({'farm_id': farmId}));
      final response = await _client.unary(
        '$_basePath/GetFarmHistory',
        body: body as dynamic,
      );
      final data =
          jsonDecode(utf8.decode(response.body)) as Map<String, dynamic>;
      final records = (data['records'] as List<dynamic>?) ?? [];

      return records
          .map((r) =>
              ProduceRecordModel.fromJson(r as Map<String, dynamic>))
          .toList();
    } on ConnectException catch (e) {
      _log.severe('Failed to fetch farm history: $e');
      rethrow;
    }
  }
}
