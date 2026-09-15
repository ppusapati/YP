import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:flutter_network/flutter_network.dart';
import 'package:flutter_proto/src/generated/inspection.pb.dart'
    as inspection_pb;
import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart'
    as ts;

import '../models/inspection_model.dart';

/// Remote data source for field inspection operations.
abstract class FieldInspectionRemoteDataSource {
  Future<List<InspectionModel>> getInspections({String? farmId});
  Future<InspectionModel> getInspectionById(String id);
  Future<InspectionModel> createInspection(InspectionModel inspection);
  Future<InspectionModel> submitInspection(String inspectionId);
}

class FieldInspectionRemoteDataSourceImpl
    implements FieldInspectionRemoteDataSource {
  final ConnectClient _client;

  FieldInspectionRemoteDataSourceImpl(this._client);

  static const _basePath = '/agriculture.agronomy.v1.InspectionService';

  Future<ConnectResponse> _call(
      String method, $pb.GeneratedMessage request) async {
    final response = await _client.unary(
      '$_basePath/$method',
      body: request.writeToBuffer(),
    );
    if (!response.isSuccess) {
      throw FieldInspectionRemoteException(
        'RPC call $_basePath/$method failed',
        statusCode: response.statusCode,
      );
    }
    return response;
  }

  @override
  Future<List<InspectionModel>> getInspections({String? farmId}) async {
    final request = inspection_pb.ListInspectionsRequest();
    if (farmId != null) request.farmId = farmId;
    final response = await _call('ListInspections', request);
    final result =
        inspection_pb.ListInspectionsResponse.fromBuffer(response.body);
    return result.inspections.map(_inspectionFromPb).toList();
  }

  @override
  Future<InspectionModel> getInspectionById(String id) async {
    final request = inspection_pb.GetInspectionRequest(id: id);
    final response = await _call('GetInspection', request);
    final result =
        inspection_pb.GetInspectionResponse.fromBuffer(response.body);
    return _inspectionFromPb(result.inspection);
  }

  @override
  Future<InspectionModel> createInspection(InspectionModel inspection) async {
    final request = inspection_pb.CreateInspectionRequest(
      fieldId: inspection.fieldId,
      farmId: inspection.farmId,
      notes: inspection.notes,
      healthScore: inspection.healthScore,
    );
    // Set inspection date from model.
    final epochSeconds = inspection.date.millisecondsSinceEpoch ~/ 1000;
    request.inspectionDate = ts.Timestamp(
      seconds: fixnum.Int64(epochSeconds),
    );

    // Convert issues.
    for (final issue in inspection.issues) {
      request.issues.add(inspection_pb.InspectionIssue(
        description: issue.description,
        severity: _issueSeverityFromString(issue.severity),
        photoUrl: issue.photoUrl ?? '',
      ));
    }

    final response = await _call('CreateInspection', request);
    final result =
        inspection_pb.CreateInspectionResponse.fromBuffer(response.body);
    return _inspectionFromPb(result.inspection);
  }

  @override
  Future<InspectionModel> submitInspection(String inspectionId) async {
    final request = inspection_pb.SubmitInspectionRequest(id: inspectionId);
    final response = await _call('SubmitInspection', request);
    final result =
        inspection_pb.SubmitInspectionResponse.fromBuffer(response.body);
    return _inspectionFromPb(result.inspection);
  }

  static inspection_pb.IssueSeverity _issueSeverityFromString(String s) {
    switch (s) {
      case 'critical':
        return inspection_pb.IssueSeverity.ISSUE_SEVERITY_CRITICAL;
      case 'high':
        return inspection_pb.IssueSeverity.ISSUE_SEVERITY_HIGH;
      case 'medium':
        return inspection_pb.IssueSeverity.ISSUE_SEVERITY_MEDIUM;
      case 'low':
        return inspection_pb.IssueSeverity.ISSUE_SEVERITY_LOW;
      default:
        return inspection_pb.IssueSeverity.ISSUE_SEVERITY_UNSPECIFIED;
    }
  }

  static String _issueSeverityToString(inspection_pb.IssueSeverity severity) {
    switch (severity) {
      case inspection_pb.IssueSeverity.ISSUE_SEVERITY_CRITICAL:
        return 'critical';
      case inspection_pb.IssueSeverity.ISSUE_SEVERITY_HIGH:
        return 'high';
      case inspection_pb.IssueSeverity.ISSUE_SEVERITY_MEDIUM:
        return 'medium';
      case inspection_pb.IssueSeverity.ISSUE_SEVERITY_LOW:
        return 'low';
      default:
        return 'low';
    }
  }

  static String _inspectionStatusToString(
      inspection_pb.InspectionStatus status) {
    switch (status) {
      case inspection_pb.InspectionStatus.INSPECTION_STATUS_DRAFT:
        return 'draft';
      case inspection_pb.InspectionStatus.INSPECTION_STATUS_SUBMITTED:
        return 'submitted';
      case inspection_pb.InspectionStatus.INSPECTION_STATUS_REVIEWED:
        return 'reviewed';
      default:
        return 'draft';
    }
  }

  static InspectionModel _inspectionFromPb(
      inspection_pb.Inspection inspection) {
    return InspectionModel(
      id: inspection.id,
      fieldId: inspection.fieldId,
      farmId: inspection.farmId,
      date: inspection.hasInspectionDate()
          ? DateTime.fromMillisecondsSinceEpoch(
              inspection.inspectionDate.seconds.toInt() * 1000)
          : (inspection.hasCreatedAt()
              ? DateTime.fromMillisecondsSinceEpoch(
                  inspection.createdAt.seconds.toInt() * 1000)
              : DateTime.now()),
      notes: inspection.notes,
      healthScore: inspection.healthScore,
      issues: inspection.issues
          .map((issue) => InspectionIssueModel(
                description: issue.description,
                severity: _issueSeverityToString(issue.severity),
                photoUrl: issue.hasPhotoUrl() ? issue.photoUrl : null,
              ))
          .toList(),
      status: _inspectionStatusToString(inspection.status),
    );
  }
}

class FieldInspectionRemoteException implements Exception {
  final String message;
  final int? statusCode;

  const FieldInspectionRemoteException(this.message, {this.statusCode});

  @override
  String toString() =>
      'FieldInspectionRemoteException($message, statusCode: $statusCode)';
}
