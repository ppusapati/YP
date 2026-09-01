import 'package:flutter_network/flutter_network.dart';
import 'package:flutter_proto/src/generated/diagnosis.pb.dart' as diagnosis_pb;
import 'package:protobuf/protobuf.dart' as $pb;

import '../models/diagnosis_model.dart';

abstract class DiagnosisRemoteDataSource {
  Future<DiagnosisModel> submitDiagnosis(DiagnosisModel diagnosis);
  Future<List<DiagnosisModel>> getDiagnoses({String? fieldId});
  Future<DiagnosisModel> getDiagnosisById(String id);
}

class DiagnosisRemoteDataSourceImpl implements DiagnosisRemoteDataSource {
  final ConnectClient _client;

  static const _basePath = '/agriculture.diagnosis.v1.PlantDiagnosisService';

  DiagnosisRemoteDataSourceImpl(this._client);

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
  Future<DiagnosisModel> submitDiagnosis(DiagnosisModel diagnosis) async {
    final request = diagnosis_pb.SubmitDiagnosisRequest(
      fieldId: diagnosis.fieldId,
      notes: diagnosis.treatment,
    );
    final response = await _call('SubmitDiagnosis', request);
    final pbResponse =
        diagnosis_pb.SubmitDiagnosisResponse.fromBuffer(response.body);
    return _diagnosisFromProto(pbResponse.diagnosis);
  }

  @override
  Future<List<DiagnosisModel>> getDiagnoses({String? fieldId}) async {
    final request = diagnosis_pb.ListDiagnosesRequest(
      fieldId: fieldId,
    );
    final response = await _call('ListDiagnoses', request);
    final pbResponse =
        diagnosis_pb.ListDiagnosesResponse.fromBuffer(response.body);
    return pbResponse.diagnoses.map(_diagnosisFromProto).toList();
  }

  @override
  Future<DiagnosisModel> getDiagnosisById(String id) async {
    final request = diagnosis_pb.GetDiagnosisRequest(id: id);
    final response = await _call('GetDiagnosis', request);
    final pbResponse =
        diagnosis_pb.GetDiagnosisResponse.fromBuffer(response.body);
    return _diagnosisFromProto(pbResponse.diagnosis);
  }

  /// Converts a protobuf [diagnosis_pb.DiagnosisRequest] to [DiagnosisModel].
  ///
  /// The proto response type wraps a [diagnosis_pb.DiagnosisRequest] message
  /// (not to be confused with an RPC request -- it is the diagnosis record).
  static DiagnosisModel _diagnosisFromProto(diagnosis_pb.DiagnosisRequest pb) {
    final diagnosedAt = pb.hasCreatedAt()
        ? DateTime.fromMillisecondsSinceEpoch(
            pb.createdAt.seconds.toInt() * 1000)
        : DateTime.now();
    final result = pb.hasResult() ? pb.result : null;
    final primaryDisease = result != null && result.detectedDiseases.isNotEmpty
        ? result.detectedDiseases.first
        : null;
    return DiagnosisModel(
      id: pb.id,
      fieldId: pb.fieldId,
      diseaseName: primaryDisease?.diseaseName ?? '',
      confidence: primaryDisease?.confidenceScore ?? 0,
      severity: primaryDisease?.severity.name ?? 'mild',
      treatment: pb.notes,
      imageUrl:
          pb.images.isNotEmpty ? pb.images.first.imageUrl : null,
      diagnosedAt: diagnosedAt,
    );
  }
}
