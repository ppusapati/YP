import 'package:flutter_network/flutter_network.dart';
import 'package:flutter_proto/src/generated/traceability.pb.dart'
    as trace_pb;
import 'package:latlong2/latlong.dart';
import 'package:logging/logging.dart';
import 'package:protobuf/protobuf.dart' as $pb;

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
      '/agriculture.traceability.v1.TraceabilityService';

  Future<ConnectResponse> _call(
      String method, $pb.GeneratedMessage request) async {
    final response = await _client.unary(
      '$_basePath/$method',
      body: request.writeToBuffer(),
    );
    if (!response.isSuccess) {
      throw ConnectException(
        code: 'internal',
        message: '$_basePath/$method failed',
        statusCode: response.statusCode,
      );
    }
    return response;
  }

  @override
  Future<ProduceRecordModel> scanQrCode(String qrData) async {
    try {
      final request = trace_pb.VerifyQRCodeRequest(qrData: qrData);
      final response = await _call('VerifyQRCode', request);
      final pbResponse =
          trace_pb.VerifyQRCodeResponse.fromBuffer(response.body);
      return _recordFromPb(pbResponse.record);
    } on ConnectException catch (e) {
      _log.severe('Failed to scan QR code: $e');
      rethrow;
    }
  }

  @override
  Future<ProduceRecordModel> fetchProduceRecord(String recordId) async {
    try {
      final request = trace_pb.GetRecordRequest(id: recordId);
      final response = await _call('GetRecord', request);
      final pbResponse =
          trace_pb.GetRecordResponse.fromBuffer(response.body);
      return _recordFromPb(pbResponse.record);
    } on ConnectException catch (e) {
      _log.severe('Failed to fetch produce record $recordId: $e');
      rethrow;
    }
  }

  @override
  Future<List<ProduceRecordModel>> fetchFarmHistory(String farmId) async {
    try {
      final request = trace_pb.ListRecordsRequest(farmId: farmId);
      final response = await _call('ListRecords', request);
      final pbResponse =
          trace_pb.ListRecordsResponse.fromBuffer(response.body);
      return pbResponse.records.map(_recordFromPb).toList();
    } on ConnectException catch (e) {
      _log.severe('Failed to fetch farm history: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Pb-to-model helpers
  // ---------------------------------------------------------------------------

  static ProduceRecordModel _recordFromPb(trace_pb.TraceabilityRecord r) {
    // Extract farm_name from metadata if available, fall back to farmId.
    final farmName = r.metadata.containsKey('farm_name')
        ? r.metadata['farm_name']!
        : r.farmId;

    // Convert pb Certifications to model CertificationModels.
    final certs = r.certifications.map((trace_pb.Certification c) {
      return CertificationModel(
        name: c.certType.name,
        issuer: c.issuedBy,
        validUntil: c.hasExpiryDate()
            ? DateTime.fromMillisecondsSinceEpoch(
                c.expiryDate.seconds.toInt() * 1000 +
                    c.expiryDate.nanos ~/ 1000000,
              )
            : DateTime.now(),
        certificateNumber: c.hasCertNumber() ? c.certNumber : null,
      );
    }).toList();

    // Convert supply chain events to TreatmentModels (best-effort mapping).
    final treatments = r.supplyChainEvents.map((trace_pb.SupplyChainEvent e) {
      return TreatmentModel(
        id: e.id,
        name: e.eventType.name,
        type: e.eventType.name,
        date: e.hasTimestamp()
            ? DateTime.fromMillisecondsSinceEpoch(
                e.timestamp.seconds.toInt() * 1000 +
                    e.timestamp.nanos ~/ 1000000,
              )
            : DateTime.now(),
        notes: e.hasDetails() ? e.details : null,
      );
    }).toList();

    // Parse farm location from metadata if available.
    final lat = double.tryParse(r.metadata['farm_lat'] ?? '') ?? 0.0;
    final lng = double.tryParse(r.metadata['farm_lng'] ?? '') ?? 0.0;

    return ProduceRecordModel(
      id: r.id,
      farmId: r.farmId,
      farmName: farmName,
      cropVariety: r.productType.isNotEmpty ? r.productType : r.cropId,
      harvestDate: r.hasHarvestDate()
          ? DateTime.fromMillisecondsSinceEpoch(
              r.harvestDate.seconds.toInt() * 1000 +
                  r.harvestDate.nanos ~/ 1000000,
            )
          : DateTime.now(),
      treatments: treatments,
      farmLocation: LatLng(lat, lng),
      certifications: certs,
      batchId: r.batchNumber,
      packingDate: r.hasPackagingDate()
          ? DateTime.fromMillisecondsSinceEpoch(
              r.packagingDate.seconds.toInt() * 1000 +
                  r.packagingDate.nanos ~/ 1000000,
            )
          : null,
      notes: r.metadata.containsKey('notes') ? r.metadata['notes'] : null,
    );
  }
}
