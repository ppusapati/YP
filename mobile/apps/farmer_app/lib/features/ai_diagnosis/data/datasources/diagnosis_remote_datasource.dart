import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_network/flutter_network.dart';
import 'package:flutter_proto/src/generated/diagnosis.pb.dart';
import 'package:logging/logging.dart';
import 'package:protobuf/protobuf.dart' as $pb;

import '../../domain/entities/diagnosis_entity.dart' show DiagnosisSeverity;
import '../models/diagnosis_model.dart';
import 'package:flutter_ui_core/flutter_ui_core.dart' show ModelExplanation;

import '../models/explanation_mapper.dart';

/// Remote data source for AI diagnosis using ConnectRPC.
abstract class DiagnosisRemoteDataSource {
  Future<DiagnosisModel> submitDiagnosis({
    required String fieldId,
    required String imagePath,
  });


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
    // Read the photo off the device and send it.
    //
    // This used to pass `imagePath` straight through as `imageUrl`, which
    // meant the server received something like
    // `/data/user/0/in.p9e.farmer/cache/CAP1234.jpg` — a path only this phone
    // can resolve. plant-diagnosis-service accepts https and s3 URLs only, so
    // it rejected every one, the AI gateway got no bytes, and the diagnosis
    // came back empty. The photo never left the device.
    final file = File(imagePath);
    final Uint8List bytes;
    try {
      bytes = await file.readAsBytes();
    } on FileSystemException catch (e) {
      // Said plainly: the capture is gone from the cache, which is a
      // different problem from the server refusing it.
      throw ConnectException(
        code: 'not_found',
        message: 'Could not read the photo at $imagePath: ${e.message}',
      );
    }

    if (bytes.length > maxImageBytes) {
      // Rejected here rather than after a slow upload on a rural connection
      // that then fails at the far end with a transport error.
      throw ConnectException(
        code: 'invalid_argument',
        message: 'That photo is ${(bytes.length / (1 << 20)).toStringAsFixed(1)} MB; '
            'the limit is ${maxImageBytes >> 20} MB.',
      );
    }

    try {
      final request = SubmitDiagnosisRequest(
        fieldId: fieldId,
        images: [
          ImageInput(
            imageBytes: bytes,
            mimeType: _mimeTypeFor(imagePath),
            imageType: ImageType.IMAGE_TYPE_LEAF,
          ),
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

  /// The ceiling plant-diagnosis-service enforces on a single image.
  static const maxImageBytes = 16 << 20;

  /// Best-effort content type from the file extension.
  ///
  /// image_picker writes JPEG for a camera capture but keeps the original
  /// format for a gallery pick, and the server stores whatever it is told.
  static String _mimeTypeFor(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.heic') || lower.endsWith('.heif')) return 'image/heic';
    return 'image/jpeg';
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
    // Why the model answered the way it did, one per analysed photo. The
    // service returns these on the result and this mapper used to drop them,
    // so the app had no way to show what the model looked at even though the
    // bytes arrived over the wire.
    List<ModelExplanation> explanations = const [];

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
      explanations =
          diagResult.explanations.map(modelExplanationFromProto).toList();
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
      explanations: explanations,
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
