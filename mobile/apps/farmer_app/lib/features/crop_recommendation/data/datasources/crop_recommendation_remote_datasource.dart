import 'dart:convert';

import 'package:flutter_network/flutter_network.dart';

import '../models/crop_recommendation_model.dart';

abstract class CropRecommendationRemoteDataSource {
  Future<List<CropRecommendationModel>> getRecommendations({
    required String fieldId,
  });
}

class CropRecommendationRemoteDataSourceImpl
    implements CropRecommendationRemoteDataSource {
  const CropRecommendationRemoteDataSourceImpl(this._client);

  final ConnectClient _client;

  static const _basePath =
      '/yieldpoint.recommendation.v1.RecommendationService';

  @override
  Future<List<CropRecommendationModel>> getRecommendations({
    required String fieldId,
  }) async {
    final body = jsonEncode({'field_id': fieldId});

    final response = await _client.unary(
      '$_basePath/GetCropRecommendations',
      body: utf8.encoder.convert(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (!response.isSuccess) {
      throw const ConnectException(
        code: 'internal',
        message: 'Failed to fetch crop recommendations',
      );
    }

    final data =
        jsonDecode(utf8.decode(response.body)) as Map<String, dynamic>;
    final recs = data['recommendations'] as List<dynamic>? ?? [];
    return recs
        .map((e) =>
            CropRecommendationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
