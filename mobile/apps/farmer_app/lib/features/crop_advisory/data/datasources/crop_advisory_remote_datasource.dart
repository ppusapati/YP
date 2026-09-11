import 'package:flutter_network/flutter_network.dart';
import 'package:flutter_proto/src/generated/advisory.pb.dart' as advisory_pb;
import 'package:protobuf/protobuf.dart' as $pb;

import '../models/advisory_model.dart';

/// Remote data source for crop advisory operations.
abstract class CropAdvisoryRemoteDataSource {
  Future<List<AdvisoryModel>> getAdvisories({String? farmId});
  Future<AdvisoryModel> getAdvisoryById(String id);
  Future<AdvisoryModel> createAdvisory(AdvisoryModel advisory);
}

class CropAdvisoryRemoteDataSourceImpl implements CropAdvisoryRemoteDataSource {
  final ConnectClient _client;

  CropAdvisoryRemoteDataSourceImpl(this._client);

  static const _basePath = '/agriculture.agronomy.v1.AdvisoryService';

  Future<ConnectResponse> _call(
      String method, $pb.GeneratedMessage request) async {
    final response = await _client.unary(
      '$_basePath/$method',
      body: request.writeToBuffer(),
    );
    if (!response.isSuccess) {
      throw CropAdvisoryRemoteException(
        'RPC call $_basePath/$method failed',
        statusCode: response.statusCode,
      );
    }
    return response;
  }

  @override
  Future<List<AdvisoryModel>> getAdvisories({String? farmId}) async {
    final request = advisory_pb.ListAdvisoriesRequest();
    if (farmId != null) request.farmId = farmId;
    final response = await _call('ListAdvisories', request);
    final result =
        advisory_pb.ListAdvisoriesResponse.fromBuffer(response.body);
    return result.advisories.map(_advisoryFromPb).toList();
  }

  @override
  Future<AdvisoryModel> getAdvisoryById(String id) async {
    final request = advisory_pb.GetAdvisoryRequest(id: id);
    final response = await _call('GetAdvisory', request);
    final result = advisory_pb.GetAdvisoryResponse.fromBuffer(response.body);
    return _advisoryFromPb(result.advisory);
  }

  @override
  Future<AdvisoryModel> createAdvisory(AdvisoryModel advisory) async {
    final request = advisory_pb.CreateAdvisoryRequest(
      title: advisory.cropName,
      content: advisory.recommendation,
      cropType: advisory.cropName,
      farmId: advisory.farmId,
      fieldId: advisory.fieldId,
    );
    // Map priority string to severity enum.
    switch (advisory.priority) {
      case 'critical':
        request.severity =
            advisory_pb.AdvisorySeverity.ADVISORY_SEVERITY_CRITICAL;
        break;
      case 'high':
        request.severity = advisory_pb.AdvisorySeverity.ADVISORY_SEVERITY_HIGH;
        break;
      case 'medium':
        request.severity =
            advisory_pb.AdvisorySeverity.ADVISORY_SEVERITY_MEDIUM;
        break;
      default:
        request.severity = advisory_pb.AdvisorySeverity.ADVISORY_SEVERITY_LOW;
    }

    final response = await _call('CreateAdvisory', request);
    final result =
        advisory_pb.CreateAdvisoryResponse.fromBuffer(response.body);
    return _advisoryFromPb(result.advisory);
  }

  static AdvisoryModel _advisoryFromPb(advisory_pb.Advisory advisory) {
    String priority;
    switch (advisory.severity) {
      case advisory_pb.AdvisorySeverity.ADVISORY_SEVERITY_CRITICAL:
        priority = 'critical';
        break;
      case advisory_pb.AdvisorySeverity.ADVISORY_SEVERITY_HIGH:
        priority = 'high';
        break;
      case advisory_pb.AdvisorySeverity.ADVISORY_SEVERITY_MEDIUM:
        priority = 'medium';
        break;
      default:
        priority = 'normal';
    }

    return AdvisoryModel(
      id: advisory.id,
      farmId: advisory.farmId,
      fieldId: advisory.fieldId,
      cropName: advisory.cropType,
      recommendation: advisory.content,
      plantingDate: advisory.hasCreatedAt()
          ? DateTime.fromMillisecondsSinceEpoch(
              advisory.createdAt.seconds.toInt() * 1000)
          : DateTime.now(),
      priority: priority,
      createdAt: advisory.hasCreatedAt()
          ? DateTime.fromMillisecondsSinceEpoch(
              advisory.createdAt.seconds.toInt() * 1000)
          : DateTime.now(),
    );
  }
}

class CropAdvisoryRemoteException implements Exception {
  final String message;
  final int? statusCode;

  const CropAdvisoryRemoteException(this.message, {this.statusCode});

  @override
  String toString() =>
      'CropAdvisoryRemoteException($message, statusCode: $statusCode)';
}
