import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_network/flutter_network.dart';
import 'package:logging/logging.dart';

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
  final _log = Logger('FieldInspectionRemoteDataSource');

  FieldInspectionRemoteDataSourceImpl(this._client);

  Future<Map<String, dynamic>> _post(
      String method, Map<String, dynamic> body) async {
    final path = '/yieldpoint.agronomy.v1.InspectionService/$method';
    _log.fine('POST $path');

    final response = await _client.unary(
      path,
      body: Uint8List.fromList(utf8.encode(jsonEncode(body))),
      headers: {'Content-Type': 'application/json'},
    );

    if (!response.isSuccess) {
      throw Exception('RPC call InspectionService/$method failed');
    }

    return jsonDecode(utf8.decode(response.body)) as Map<String, dynamic>;
  }

  @override
  Future<List<InspectionModel>> getInspections({String? farmId}) async {
    final body = <String, dynamic>{};
    if (farmId != null) body['farm_id'] = farmId;
    final data = await _post('ListInspections', body);
    final list = data['inspections'] as List<dynamic>? ?? [];
    return list
        .map((e) => InspectionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<InspectionModel> getInspectionById(String id) async {
    final data = await _post('GetInspection', {'id': id});
    return InspectionModel.fromJson(
        data['inspection'] as Map<String, dynamic>);
  }

  @override
  Future<InspectionModel> createInspection(InspectionModel inspection) async {
    final data = await _post('CreateInspection', {
      'inspection': inspection.toJson(),
    });
    return InspectionModel.fromJson(
        data['inspection'] as Map<String, dynamic>);
  }

  @override
  Future<InspectionModel> submitInspection(String inspectionId) async {
    final data = await _post('SubmitInspection', {'id': inspectionId});
    return InspectionModel.fromJson(
        data['inspection'] as Map<String, dynamic>);
  }
}
