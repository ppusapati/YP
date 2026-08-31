import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_network/flutter_network.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import '../models/diagnosis_model.dart';

/// Remote data source for AI diagnosis using ConnectRPC.
abstract class DiagnosisRemoteDataSource {
  Future<DiagnosisModel> submitDiagnosis({
    required String fieldId,
    required String imagePath,
  });

  Future<String> uploadImage(Uint8List imageBytes, String fileName);

  Future<List<DiagnosisModel>> getDiagnosisHistory({String? fieldId});
  Future<DiagnosisModel> getDiagnosisById(String diagnosisId);
}

/// ConnectRPC-based implementation of [DiagnosisRemoteDataSource].
class DiagnosisRemoteDataSourceImpl implements DiagnosisRemoteDataSource {
  final ApiConfig _apiConfig;
  final http.Client _httpClient;
  final _log = Logger('DiagnosisRemoteDataSource');

  DiagnosisRemoteDataSourceImpl({
    required ApiConfig apiConfig,
    required http.Client httpClient,
  })  : _apiConfig = apiConfig,
        _httpClient = httpClient;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        ..._apiConfig.headers,
      };

  String _buildUrl(String service, String method) =>
      '${_apiConfig.origin}/yieldpoint.diagnosis.v1.$service/$method';

  Future<Map<String, dynamic>> _post(
      String service, String method, Map<String, dynamic> body) async {
    final url = _buildUrl(service, method);
    _log.fine('POST $url');

    final response = await _httpClient
        .post(
          Uri.parse(url),
          headers: _headers,
          body: jsonEncode(body),
        )
        .timeout(_apiConfig.timeout);

    if (response.statusCode != 200) {
      _log.severe('RPC error ${response.statusCode}: ${response.body}');
      throw DiagnosisRemoteException(
        'RPC call $service/$method failed',
        statusCode: response.statusCode,
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  @override
  Future<DiagnosisModel> submitDiagnosis({
    required String fieldId,
    required String imagePath,
  }) async {
    final data = await _post('DiagnosisService', 'SubmitDiagnosis', {
      'field_id': fieldId,
      'image_path': imagePath,
    });
    return DiagnosisModel.fromProto(
        data['diagnosis'] as Map<String, dynamic>);
  }

  @override
  Future<String> uploadImage(Uint8List imageBytes, String fileName) async {
    final url =
        '${_apiConfig.origin}/yieldpoint.diagnosis.v1.DiagnosisService/UploadImage';
    _log.fine('Uploading image: $fileName (${imageBytes.length} bytes)');

    final request = http.MultipartRequest('POST', Uri.parse(url))
      ..headers.addAll(_apiConfig.headers)
      ..files.add(http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: fileName,
      ));

    final streamedResponse =
        await request.send().timeout(_apiConfig.timeout);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw DiagnosisRemoteException(
        'Image upload failed',
        statusCode: response.statusCode,
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['image_url'] as String;
  }

  @override
  Future<List<DiagnosisModel>> getDiagnosisHistory({String? fieldId}) async {
    final body = <String, dynamic>{};
    if (fieldId != null) body['field_id'] = fieldId;

    final data =
        await _post('DiagnosisService', 'ListDiagnoses', body);
    final diagnoses = data['diagnoses'] as List<dynamic>? ?? [];
    return diagnoses
        .map((d) => DiagnosisModel.fromProto(d as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<DiagnosisModel> getDiagnosisById(String diagnosisId) async {
    final data = await _post('DiagnosisService', 'GetDiagnosis', {
      'id': diagnosisId,
    });
    return DiagnosisModel.fromProto(
        data['diagnosis'] as Map<String, dynamic>);
  }
}

/// Exception thrown when a remote diagnosis API call fails.
class DiagnosisRemoteException implements Exception {
  final String message;
  final int? statusCode;

  const DiagnosisRemoteException(this.message, {this.statusCode});

  @override
  String toString() =>
      'DiagnosisRemoteException($message, statusCode: $statusCode)';
}
