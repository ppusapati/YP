import 'dart:convert';
import 'dart:io';

import 'package:flutter_network/flutter_network.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import '../models/observation_model.dart';

/// Remote data source for field observations via ConnectRPC.
abstract class ObservationRemoteDataSource {
  Future<List<ObservationModel>> fetchObservations({String? fieldId});
  Future<List<ObservationModel>> fetchFieldObservations(String fieldId);
  Future<ObservationModel> fetchObservationById(String observationId);
  Future<ObservationModel> createObservation(ObservationModel observation);
  Future<void> deleteObservation(String observationId);
  Future<String> uploadPhoto(String localPath);
}

class ObservationRemoteDataSourceImpl implements ObservationRemoteDataSource {
  ObservationRemoteDataSourceImpl({required ConnectClient client})
      : _client = client;

  final ConnectClient _client;
  static final _log = Logger('ObservationRemoteDataSource');

  static const _basePath = '/yieldpoint.observation.v1.ObservationService';

  @override
  Future<List<ObservationModel>> fetchObservations({String? fieldId}) async {
    try {
      final params = <String, dynamic>{};
      if (fieldId != null) params['field_id'] = fieldId;

      final body = params.isNotEmpty
          ? utf8.encode(jsonEncode(params)) as dynamic
          : null;

      final response =
          await _client.unary('$_basePath/GetObservations', body: body);
      final data =
          jsonDecode(utf8.decode(response.body)) as Map<String, dynamic>;
      final observations = (data['observations'] as List<dynamic>?) ?? [];

      return observations
          .map((o) => ObservationModel.fromJson(o as Map<String, dynamic>))
          .toList();
    } on ConnectException catch (e) {
      _log.severe('Failed to fetch observations: $e');
      rethrow;
    }
  }

  @override
  Future<List<ObservationModel>> fetchFieldObservations(
    String fieldId,
  ) async {
    return fetchObservations(fieldId: fieldId);
  }

  @override
  Future<ObservationModel> fetchObservationById(String observationId) async {
    try {
      final body =
          utf8.encode(jsonEncode({'observation_id': observationId}));
      final response = await _client.unary(
        '$_basePath/GetObservation',
        body: body as dynamic,
      );
      final data =
          jsonDecode(utf8.decode(response.body)) as Map<String, dynamic>;
      return ObservationModel.fromJson(data);
    } on ConnectException catch (e) {
      _log.severe('Failed to fetch observation $observationId: $e');
      rethrow;
    }
  }

  @override
  Future<ObservationModel> createObservation(
    ObservationModel observation,
  ) async {
    try {
      final body = utf8.encode(jsonEncode(observation.toJson()));
      final response = await _client.unary(
        '$_basePath/CreateObservation',
        body: body as dynamic,
      );
      final data =
          jsonDecode(utf8.decode(response.body)) as Map<String, dynamic>;
      return ObservationModel.fromJson(data);
    } on ConnectException catch (e) {
      _log.severe('Failed to create observation: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteObservation(String observationId) async {
    try {
      final body =
          utf8.encode(jsonEncode({'observation_id': observationId}));
      await _client.unary(
        '$_basePath/DeleteObservation',
        body: body as dynamic,
      );
    } on ConnectException catch (e) {
      _log.severe('Failed to delete observation: $e');
      rethrow;
    }
  }

  @override
  Future<String> uploadPhoto(String localPath) async {
    try {
      final file = File(localPath);
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);

      final body = utf8.encode(jsonEncode({
        'file_name': localPath.split('/').last,
        'content': base64Image,
      }));

      final response = await _client.unary(
        '$_basePath/UploadPhoto',
        body: body as dynamic,
      );

      final data =
          jsonDecode(utf8.decode(response.body)) as Map<String, dynamic>;
      return data['url'] as String;
    } on ConnectException catch (e) {
      _log.severe('Failed to upload photo: $e');
      rethrow;
    }
  }
}
