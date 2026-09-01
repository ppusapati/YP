import 'dart:typed_data';

import 'package:flutter_network/flutter_network.dart';
import 'package:flutter_proto/src/generated/diagnosis.pb.dart';
import 'package:logging/logging.dart';
import 'package:protobuf/protobuf.dart' as $pb;

import '../../domain/entities/diagnosis_entity.dart' show DiagnosisSeverity;
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
  final ConnectClient _client;
  final _log = Logger('DiagnosisRemoteDataSource');
  static const _basePath = '/agriculture.diagnosis.v1.PlantDiagnosisService';

  DiagnosisRemoteDataSourceImpl({required ConnectClient client})
      : _client = client;

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
  Future<DiagnosisModel> submitDiagnosis({
    required String fieldId,
    required String imagePath,
  }) async {
    try {
      // The proto SubmitDiagnosisRequest uses structured ImageInput objects
      // with imageUrl (not a raw path). The imagePath should be a URL obtained
      // from a prior uploadImage call.
      final request = SubmitDiagnosisRequest(
        fieldId: fieldId,
        images: [
          ImageInput(imageUrl: imagePath),
        ],
      );
      final response = await _call('SubmitDiagnosis', request);
      final result = SubmitDiagnosisResponse.fromBuffer(response.body);

      return _mapDiagnosisRequestToModel(result.diagnosis);
    } on ConnectException catch (e) {
      _log.severe('Failed to submit diagnosis: $e');
      rethrow;
    }
  }

  @override
  Future<String> uploadImage(Uint8List imageBytes, String fileName) async {
    // TODO: The proto has no UploadImage RPC. Image upload is not defined in
    // the PlantDiagnosisService proto. This likely needs a separate upload
    // endpoint or a different service. Keeping the interface for compatibility.
    throw UnimplementedError(
      'uploadImage is not supported by the diagnosis proto. '
      'No UploadImage RPC exists in PlantDiagnosisService.',
    );
  }

  @override
  Future<List<DiagnosisModel>> getDiagnosisHistory({String? fieldId}) async {
    try {
      final request = ListDiagnosesRequest(
        fieldId: fieldId,
      );
      final response = await _call('ListDiagnoses', request);
      final result = ListDiagnosesResponse.fromBuffer(response.body);

      return result.diagnoses
          .map(_mapDiagnosisRequestToModel)
          .toList();
    } on ConnectException catch (e) {
      _log.severe('Failed to fetch diagnosis history: $e');
      rethrow;
    }
  }

  @override
  Future<DiagnosisModel> getDiagnosisById(String diagnosisId) async {
    try {
      final request = GetDiagnosisRequest(id: diagnosisId);
      final response = await _call('GetDiagnosis', request);
      final result = GetDiagnosisResponse.fromBuffer(response.body);

      return _mapDiagnosisRequestToModel(result.diagnosis);
    } on ConnectException catch (e) {
      _log.severe('Failed to fetch diagnosis $diagnosisId: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static DiagnosisModel _mapDiagnosisRequestToModel(
      DiagnosisRequest diagnosis) {
    // Extract first image URL if available.
    final firstImageUrl =
        diagnosis.images.isNotEmpty ? diagnosis.images.first.imageUrl : '';

    // Extract disease info from DiagnosisResult if present.
    String diseaseName = '';
    String diseaseType = '';
    double confidence = 0.0;
    DiagnosisSeverity severity = DiagnosisSeverity.healthy;
    String description = '';
    List<String> recommendations = [];
    String plantSpecies = '';

    if (diagnosis.hasResult()) {
      final diagResult = diagnosis.result;
      if (diagResult.detectedDiseases.isNotEmpty) {
        final firstDisease = diagResult.detectedDiseases.first;
        diseaseName = firstDisease.diseaseName;
        diseaseType = firstDisease.scientificName;
        confidence = firstDisease.confidenceScore;
        severity = _mapProtoSeverity(firstDisease.severity);
        description = firstDisease.description;
      }
      recommendations = List<String>.from(diagResult.treatmentRecommendations);
      if (diagResult.hasIdentifiedSpecies()) {
        plantSpecies = diagResult.identifiedSpecies.commonName;
      }
      if (description.isEmpty) {
        description = diagResult.summary;
      }
    }

    return DiagnosisModel(
      id: diagnosis.id,
      fieldId: diagnosis.fieldId,
      imagePath: firstImageUrl,
      imageUrl: firstImageUrl,
      plantSpecies: plantSpecies,
      diseaseName: diseaseName,
      diseaseType: diseaseType,
      confidence: confidence,
      severity: severity,
      description: description.isNotEmpty ? description : diagnosis.notes,
      recommendations: recommendations,
      createdAt: diagnosis.hasCreatedAt()
          ? diagnosis.createdAt.toDateTime()
          : DateTime.now(),
    );
  }

  static DiagnosisSeverity _mapProtoSeverity(Severity protoSeverity) {
    return switch (protoSeverity) {
      Severity.SEVERITY_UNSPECIFIED => DiagnosisSeverity.healthy,
      Severity.SEVERITY_MILD => DiagnosisSeverity.mild,
      Severity.SEVERITY_MODERATE => DiagnosisSeverity.moderate,
      Severity.SEVERITY_SEVERE => DiagnosisSeverity.severe,
      Severity.SEVERITY_CRITICAL => DiagnosisSeverity.severe,
      _ => DiagnosisSeverity.moderate,
    };
  }
}
