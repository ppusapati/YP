import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_network/flutter_network.dart';
import 'package:logging/logging.dart';

import '../models/advisory_model.dart';

/// Remote data source for crop advisory operations.
abstract class CropAdvisoryRemoteDataSource {
  Future<List<AdvisoryModel>> getAdvisories({String? farmId});
  Future<AdvisoryModel> getAdvisoryById(String id);
  Future<AdvisoryModel> createAdvisory(AdvisoryModel advisory);
}

class CropAdvisoryRemoteDataSourceImpl implements CropAdvisoryRemoteDataSource {
  final ConnectClient _client;
  final _log = Logger('CropAdvisoryRemoteDataSource');

  CropAdvisoryRemoteDataSourceImpl(this._client);

  Future<Map<String, dynamic>> _post(
      String method, Map<String, dynamic> body) async {
    final path = '/agriculture.agronomy.v1.AdvisoryService/$method';
    _log.fine('POST $path');

    final response = await _client.unary(
      path,
      body: Uint8List.fromList(utf8.encode(jsonEncode(body))),
      headers: {'Content-Type': 'application/json'},
    );

    if (!response.isSuccess) {
      throw Exception('RPC call AdvisoryService/$method failed');
    }

    return jsonDecode(utf8.decode(response.body)) as Map<String, dynamic>;
  }

  @override
  Future<List<AdvisoryModel>> getAdvisories({String? farmId}) async {
    final body = <String, dynamic>{};
    if (farmId != null) body['farm_id'] = farmId;
    final data = await _post('ListAdvisories', body);
    final list = data['advisories'] as List<dynamic>? ?? [];
    return list
        .map((e) => AdvisoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<AdvisoryModel> getAdvisoryById(String id) async {
    final data = await _post('GetAdvisory', {'id': id});
    return AdvisoryModel.fromJson(data['advisory'] as Map<String, dynamic>);
  }

  @override
  Future<AdvisoryModel> createAdvisory(AdvisoryModel advisory) async {
    final data = await _post('CreateAdvisory', {
      'advisory': advisory.toJson(),
    });
    return AdvisoryModel.fromJson(data['advisory'] as Map<String, dynamic>);
  }
}
