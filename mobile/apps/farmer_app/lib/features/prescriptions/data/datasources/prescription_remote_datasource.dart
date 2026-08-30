import 'dart:convert';

import 'package:flutter_network/flutter_network.dart';
import 'package:logging/logging.dart';

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

  PrescriptionRemoteDataSourceImpl(this._client);

  Future<Map<String, dynamic>> _post(
      String method, Map<String, dynamic> body) async {
    final path =
        '/agriculture.prescription.v1.PrescriptionService/$method';
    _log.fine('POST $path');

    final response = await _client.unary(
      path,
      body: utf8.encoder.convert(jsonEncode(body)),
      headers: {'Content-Type': 'application/json'},
    );

    if (!response.isSuccess) {
      throw ConnectException(
        code: 'internal',
        message: 'PrescriptionService/$method failed',
      );
    }

    return jsonDecode(utf8.decode(response.body)) as Map<String, dynamic>;
  }

  @override
  Future<List<PrescriptionBundleModel>> getPrescriptions({
    String? prescriptionType,
  }) async {
    final body = <String, dynamic>{};
    if (prescriptionType != null) {
      body['prescription_type'] = prescriptionType;
    }
    final data = await _post('ListPrescriptions', body);
    final list = data['prescriptions'] as List<dynamic>? ?? [];
    return list
        .map((e) => PrescriptionBundleModel.fromJson(
            e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<PrescriptionBundleModel> getPrescriptionById(String id) async {
    final data = await _post('GetPrescription', {'id': id});
    return PrescriptionBundleModel.fromJson(
        data['prescription'] as Map<String, dynamic>);
  }

  @override
  Future<PrescriptionBundleModel> generatePrescription({
    required String fieldId,
    required String cropType,
    required double targetYield,
    List<List<double>>? soilData,
  }) async {
    final body = <String, dynamic>{
      'field_id': fieldId,
      'crop_type': cropType,
      'target_yield': targetYield,
    };
    if (soilData != null) body['soil_data'] = soilData;
    final data = await _post('GeneratePrescription', body);
    return PrescriptionBundleModel.fromJson(
        data['prescription'] as Map<String, dynamic>);
  }
}
