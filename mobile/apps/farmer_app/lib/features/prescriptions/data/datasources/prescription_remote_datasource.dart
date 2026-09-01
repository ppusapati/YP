import 'package:flutter_network/flutter_network.dart';
import 'package:flutter_proto/src/generated/prescription.pb.dart' as rx_pb;
import 'package:logging/logging.dart';
import 'package:protobuf/protobuf.dart' as $pb;

import '../models/prescription_model.dart';

/// Remote data source for prescription operations.
abstract class PrescriptionRemoteDataSource {
  Future<List<PrescriptionBundleModel>> getPrescriptions({
    String? prescriptionType,
  });
  Future<PrescriptionBundleModel> getPrescriptionById(String id);
  Future<PrescriptionBundleModel> generatePrescription({
    required String fieldId,
    required String cropType,
    required double targetYield,
    List<List<double>>? soilData,
  });
}

class PrescriptionRemoteDataSourceImpl
    implements PrescriptionRemoteDataSource {
  final ConnectClient _client;
  final _log = Logger('PrescriptionRemoteDataSource');

  static const _basePath = '/agriculture.prescription.v1.PrescriptionService';

  PrescriptionRemoteDataSourceImpl(this._client);

  Future<ConnectResponse> _call(
      String basePath, String method, $pb.GeneratedMessage request) async {
    _log.fine('POST $basePath/$method');
    final response = await _client.unary(
      '$basePath/$method',
      body: request.writeToBuffer(),
    );
    if (!response.isSuccess) {
      throw ConnectException(
        code: 'internal',
        message: '$basePath/$method failed',
        statusCode: response.statusCode,
      );
    }
    return response;
  }

  @override
  Future<List<PrescriptionBundleModel>> getPrescriptions({
    String? prescriptionType,
  }) async {
    final request = rx_pb.ListPrescriptionsRequest(
      prescriptionType: prescriptionType != null
          ? _prescriptionTypeFromString(prescriptionType)
          : null,
    );
    final response = await _call(_basePath, 'ListPrescriptions', request);
    final result =
        rx_pb.ListPrescriptionsResponse.fromBuffer(response.body);
    return result.prescriptions.map(_bundleFromPb).toList();
  }

  @override
  Future<PrescriptionBundleModel> getPrescriptionById(String id) async {
    final request = rx_pb.GetPrescriptionRequest(id: id);
    final response = await _call(_basePath, 'GetPrescription', request);
    final result =
        rx_pb.GetPrescriptionResponse.fromBuffer(response.body);
    return _bundleFromPb(result.prescription);
  }

  @override
  Future<PrescriptionBundleModel> generatePrescription({
    required String fieldId,
    required String cropType,
    required double targetYield,
    List<List<double>>? soilData,
  }) async {
    final request = rx_pb.GeneratePrescriptionRequest(
      fieldId: fieldId,
      cropType: cropType,
      targetYield: targetYield,
      soilData: soilData
          ?.map((row) => rx_pb.SoilDataRow(values: row))
          .toList(),
    );
    final response =
        await _call(_basePath, 'GeneratePrescription', request);
    final result =
        rx_pb.GeneratePrescriptionResponse.fromBuffer(response.body);
    return _bundleFromPb(result.prescription);
  }

  // ---------------------------------------------------------------------------
  // Proto-to-model helpers
  // ---------------------------------------------------------------------------

  static PrescriptionBundleModel _bundleFromPb(
      rx_pb.PrescriptionBundle pb) {
    return PrescriptionBundleModel(
      id: pb.id,
      fieldId: pb.fieldId,
      fieldName: pb.fieldName,
      cropType: pb.cropType,
      targetYield: pb.targetYield,
      createdAt: pb.hasCreatedAt()
          ? DateTime.parse(pb.createdAt)
          : DateTime.now(),
      estimatedCostSavings:
          pb.hasEstimatedCostSavings() ? pb.estimatedCostSavings : null,
      estimatedYieldGain:
          pb.hasEstimatedYieldGain() ? pb.estimatedYieldGain : null,
      prescriptions: pb.prescriptions
          .map((m) => _prescriptionMapFromPb(m, pb.zoneSummaries))
          .toList(),
    );
  }

  static PrescriptionMapModel _prescriptionMapFromPb(
      rx_pb.PrescriptionMap m,
      List<rx_pb.ZoneSummary> allZones) {
    final matchingZones = allZones
        .where((z) => z.prescriptionType == m.prescriptionType)
        .toList();
    return PrescriptionMapModel(
      id: m.id,
      prescriptionType: _prescriptionTypeToString(m.prescriptionType),
      unit: m.unit,
      avgRate: m.avgRate,
      totalAmount:
          matchingZones.fold(0.0, (sum, z) => sum + z.totalAmount),
      rates: m.rates.expand((row) => row.values).toList(),
      zones: matchingZones.map(_zoneSummaryFromPb).toList(),
    );
  }

  static ZoneSummaryModel _zoneSummaryFromPb(rx_pb.ZoneSummary pb) {
    return ZoneSummaryModel(
      zone: pb.zone,
      areaHectares: pb.areaHectares,
      minRate: pb.minRate,
      meanRate: pb.meanRate,
      maxRate: pb.maxRate,
      totalAmount: pb.totalAmount,
    );
  }

  static rx_pb.PrescriptionType _prescriptionTypeFromString(String type) {
    return switch (type) {
      'fertilizer' => rx_pb.PrescriptionType.PRESCRIPTION_TYPE_FERTILIZER,
      'irrigation' => rx_pb.PrescriptionType.PRESCRIPTION_TYPE_IRRIGATION,
      'seeding' => rx_pb.PrescriptionType.PRESCRIPTION_TYPE_SEEDING,
      'liming' => rx_pb.PrescriptionType.PRESCRIPTION_TYPE_LIMING,
      _ => rx_pb.PrescriptionType.PRESCRIPTION_TYPE_UNSPECIFIED,
    };
  }

  static String _prescriptionTypeToString(rx_pb.PrescriptionType type) {
    return switch (type) {
      rx_pb.PrescriptionType.PRESCRIPTION_TYPE_FERTILIZER => 'fertilizer',
      rx_pb.PrescriptionType.PRESCRIPTION_TYPE_IRRIGATION => 'irrigation',
      rx_pb.PrescriptionType.PRESCRIPTION_TYPE_SEEDING => 'seeding',
      rx_pb.PrescriptionType.PRESCRIPTION_TYPE_LIMING => 'liming',
      _ => '',
    };
  }
}
