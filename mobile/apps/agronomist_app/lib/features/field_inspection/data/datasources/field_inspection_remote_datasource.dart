import 'package:flutter_network/flutter_network.dart';

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

  // No generated protobuf types exist for agriculture.agronomy.v1.InspectionService.
  // All methods throw UnimplementedError until proto definitions are available.

  @override
  Future<List<InspectionModel>> getInspections({String? farmId}) {
    throw UnimplementedError(
      'InspectionService/ListInspections has no generated protobuf request type',
    );
  }

  @override
  Future<InspectionModel> getInspectionById(String id) {
    throw UnimplementedError(
      'InspectionService/GetInspection has no generated protobuf request type',
    );
  }

  @override
  Future<InspectionModel> createInspection(InspectionModel inspection) {
    throw UnimplementedError(
      'InspectionService/CreateInspection has no generated protobuf request type',
    );
  }

  @override
  Future<InspectionModel> submitInspection(String inspectionId) {
    throw UnimplementedError(
      'InspectionService/SubmitInspection has no generated protobuf request type',
    );
  }
}
