import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_network/flutter_network.dart';
import 'package:logging/logging.dart';

import '../models/diagnosis_model.dart';

abstract class DiagnosisRemoteDataSource {
  Future<DiagnosisModel> submitDiagnosis(DiagnosisModel diagnosis);
  Future<List<DiagnosisModel>> getDiagnoses({String? fieldId});
  Future<DiagnosisModel> getDiagnosisById(String id);
}

class DiagnosisRemoteDataSourceImpl implements DiagnosisRemoteDataSource {
  final ConnectClient _client;
  final _log = Logger('DiagnosisRemoteDataSource');

  DiagnosisRemoteDataSourceImpl(this._client);

  Future<Map<String, dynamic>> _post(
      String method, Map<String, dynamic> body) async {
    final path = '/agriculture.diagnosis.v1.PlantDiagnosisService/$method';
    _log.fine('POST $path');

    final response = await _client.unary(
      path,
      body: Uint8List.fromList(utf8.encode(jsonEncode(body))),
      headers: {'Content-Type': 'application/json'},
    );

    if (!response.isSuccess) {
      throw Exception('RPC call DiagnosisService/$method failed');
    }

    return jsonDecode(utf8.decode(response.body)) as Map<String, dynamic>;
  }

  @override
  Future<DiagnosisModel> submitDiagnosis(DiagnosisModel diagnosis) async {
    final data = await _post('SubmitDiagnosis', {
      'diagnosis': diagnosis.toJson(),
    });
    return DiagnosisModel.fromJson(
        data['diagnosis'] as Map<String, dynamic>);
  }

  @override
  Future<List<DiagnosisModel>> getDiagnoses({String? fieldId}) async {
    final body = <String, dynamic>{};
    if (fieldId != null) body['field_id'] = fieldId;
    final data = await _post('ListDiagnoses', body);
    final list = data['diagnoses'] as List<dynamic>? ?? [];
    return list
        .map((e) => DiagnosisModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<DiagnosisModel> getDiagnosisById(String id) async {
    final data = await _post('GetDiagnosis', {'id': id});
    return DiagnosisModel.fromJson(
        data['diagnosis'] as Map<String, dynamic>);
  }
}
