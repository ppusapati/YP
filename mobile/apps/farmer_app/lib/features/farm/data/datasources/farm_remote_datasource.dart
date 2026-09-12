import 'dart:convert';

import 'package:flutter_network/flutter_network.dart';
import 'package:flutter_proto/src/generated/farm.pb.dart' as farm_pb;
import 'package:flutter_proto/src/generated/field.pb.dart' as field_pb;
import 'package:latlong2/latlong.dart';
import 'package:protobuf/protobuf.dart' as $pb;

import '../models/farm_model.dart';
import '../models/field_model.dart';

abstract class FarmRemoteDataSource {
  Future<List<FarmModel>> getFarms(String userId);
  Future<FarmModel> getFarmById(String farmId);
  Future<FarmModel> createFarm(FarmModel farm);
  Future<FarmModel> updateFarm(FarmModel farm);
  Future<void> deleteFarm(String farmId);
  Future<FieldModel> createField(FieldModel field);
  Future<FieldModel> updateField(FieldModel field);
  Future<void> deleteField(String fieldId);
  Future<List<FieldModel>> getFieldsByFarmId(String farmId);
}

class FarmRemoteDataSourceImpl implements FarmRemoteDataSource {
  final ConnectClient _client;

  FarmRemoteDataSourceImpl({required ConnectClient client}) : _client = client;

  static const _farmPath = '/agriculture.farm.v1.FarmService';
  static const _fieldPath = '/agriculture.field.v1.FieldService';

  Future<ConnectResponse> _call(
      String basePath, String method, $pb.GeneratedMessage request) async {
    final response = await _client.unary(
      '$basePath/$method',
      body: request.writeToBuffer(),
    );
    if (!response.isSuccess) {
      throw FarmRemoteException(
        'RPC call $basePath/$method failed',
        statusCode: response.statusCode,
      );
    }
    return response;
  }

  @override
  Future<List<FarmModel>> getFarms(String userId) async {
    final request = farm_pb.ListFarmsRequest();
    final response = await _call(_farmPath, 'ListFarms', request);
    final result = farm_pb.ListFarmsResponse.fromBuffer(response.body);
    return result.farms.map(_farmFromPb).toList();
  }

  @override
  Future<FarmModel> getFarmById(String farmId) async {
    final request = farm_pb.GetFarmRequest(id: farmId);
    final response = await _call(_farmPath, 'GetFarm', request);
    final result = farm_pb.GetFarmResponse.fromBuffer(response.body);
    return _farmFromPb(result.farm);
  }

  @override
  Future<FarmModel> createFarm(FarmModel farm) async {
    final centroid = _centroid(farm.boundaries);
    final request = farm_pb.CreateFarmRequest(
      name: farm.name,
      totalAreaHectares: farm.totalAreaHectares,
      location: centroid,
    );
    final response = await _call(_farmPath, 'CreateFarm', request);
    final result = farm_pb.CreateFarmResponse.fromBuffer(response.body);
    final created = result.farm;

    if (farm.boundaries.length >= 3) {
      final geojson = _boundariesToGeoJson(farm.boundaries);
      final boundaryReq = farm_pb.SetFarmBoundaryRequest(
        farmId: created.id,
        geojson: geojson,
      );
      await _call(_farmPath, 'SetFarmBoundary', boundaryReq);
    }

    final model = _farmFromPb(created);
    return FarmModel(
      id: model.id,
      name: model.name,
      ownerId: model.ownerId,
      boundaries: farm.boundaries,
      totalAreaHectares: model.totalAreaHectares,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  static farm_pb.FarmLocation? _centroid(List<LatLng> points) {
    if (points.isEmpty) return null;
    final lat = points.fold(0.0, (s, p) => s + p.latitude) / points.length;
    final lng = points.fold(0.0, (s, p) => s + p.longitude) / points.length;
    return farm_pb.FarmLocation(latitude: lat, longitude: lng);
  }

  static String _boundariesToGeoJson(List<LatLng> points) {
    final coords = points.map((p) => [p.longitude, p.latitude]).toList();
    if (coords.isNotEmpty && (coords.first[0] != coords.last[0] || coords.first[1] != coords.last[1])) {
      coords.add(coords.first);
    }
    return jsonEncode({
      'type': 'Polygon',
      'coordinates': [coords],
    });
  }

  @override
  Future<FarmModel> updateFarm(FarmModel farm) async {
    final centroid = _centroid(farm.boundaries);
    final request = farm_pb.UpdateFarmRequest(
      id: farm.id,
      name: farm.name,
      totalAreaHectares: farm.totalAreaHectares,
    );
    if (centroid != null) {
      request.location = centroid;
    }
    final response = await _call(_farmPath, 'UpdateFarm', request);
    final result = farm_pb.UpdateFarmResponse.fromBuffer(response.body);

    if (farm.boundaries.length >= 3) {
      final geojson = _boundariesToGeoJson(farm.boundaries);
      final boundaryReq = farm_pb.SetFarmBoundaryRequest(
        farmId: farm.id,
        geojson: geojson,
      );
      await _call(_farmPath, 'SetFarmBoundary', boundaryReq);
    }

    return _farmFromPb(result.farm);
  }

  @override
  Future<void> deleteFarm(String farmId) async {
    final request = farm_pb.DeleteFarmRequest(id: farmId);
    await _call(_farmPath, 'DeleteFarm', request);
  }

  @override
  Future<FieldModel> createField(FieldModel field) async {
    final request = field_pb.CreateFieldRequest(
      farmId: field.farmId,
      name: field.name,
      areaHectares: field.areaHectares,
    );
    final response = await _call(_fieldPath, 'CreateField', request);
    final result = field_pb.CreateFieldResponse.fromBuffer(response.body);
    return _fieldFromPb(result.field_1);
  }

  @override
  Future<FieldModel> updateField(FieldModel field) async {
    final request = field_pb.UpdateFieldRequest(
      id: field.id,
      name: field.name,
    );
    final response = await _call(_fieldPath, 'UpdateField', request);
    final result = field_pb.UpdateFieldResponse.fromBuffer(response.body);
    return _fieldFromPb(result.field_1);
  }

  @override
  Future<void> deleteField(String fieldId) async {
    final request = field_pb.DeleteFieldRequest(id: fieldId);
    await _call(_fieldPath, 'DeleteField', request);
  }

  @override
  Future<List<FieldModel>> getFieldsByFarmId(String farmId) async {
    final request = field_pb.ListFieldsByFarmRequest(farmId: farmId);
    final response = await _call(_fieldPath, 'ListFieldsByFarm', request);
    final result = field_pb.ListFieldsByFarmResponse.fromBuffer(response.body);
    return result.fields.map(_fieldFromPb).toList();
  }

  static FarmModel _farmFromPb(farm_pb.Farm farm) {
    List<LatLng> boundaries = [];
    if (farm.hasBoundary() && farm.boundary.geojson.isNotEmpty) {
      boundaries = _parseGeoJsonBoundary(farm.boundary.geojson);
    } else if (farm.hasLocation()) {
      boundaries = [LatLng(farm.location.latitude, farm.location.longitude)];
    }

    return FarmModel(
      id: farm.id,
      name: farm.name,
      ownerId: farm.createdBy,
      boundaries: boundaries,
      totalAreaHectares: farm.totalAreaHectares,
      createdAt: farm.hasCreatedAt()
          ? DateTime.fromMillisecondsSinceEpoch(
              farm.createdAt.seconds.toInt() * 1000)
          : DateTime.now(),
      updatedAt: farm.hasUpdatedAt()
          ? DateTime.fromMillisecondsSinceEpoch(
              farm.updatedAt.seconds.toInt() * 1000)
          : DateTime.now(),
    );
  }

  static List<LatLng> _parseGeoJsonBoundary(String geojson) {
    try {
      final map = jsonDecode(geojson) as Map<String, dynamic>;
      final coords = (map['coordinates'] as List).first as List;
      return coords
          .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static FieldModel _fieldFromPb(field_pb.Field field) {
    return FieldModel(
      id: field.id,
      farmId: field.farmId,
      name: field.name,
      polygon: field.hasBoundary()
          ? field.boundary.points
              .map((p) => LatLng(p.latitude, p.longitude))
              .toList()
          : [],
      areaHectares: field.areaHectares,
    );
  }
}

class FarmRemoteException implements Exception {
  final String message;
  final int? statusCode;
  final String? body;

  const FarmRemoteException(this.message, {this.statusCode, this.body});

  @override
  String toString() =>
      'FarmRemoteException($message, statusCode: $statusCode)';
}
