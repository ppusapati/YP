// This is a generated file - do not edit.
//
// Generated from farm.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'farm.pb.dart' as $2;
import 'farm.pbjson.dart';

export 'farm.pb.dart';

abstract class FarmServiceBase extends $pb.GeneratedService {
  $async.Future<$2.CreateFarmResponse> createFarm(
      $pb.ServerContext ctx, $2.CreateFarmRequest request);
  $async.Future<$2.GetFarmResponse> getFarm(
      $pb.ServerContext ctx, $2.GetFarmRequest request);
  $async.Future<$2.ListFarmsResponse> listFarms(
      $pb.ServerContext ctx, $2.ListFarmsRequest request);
  $async.Future<$2.UpdateFarmResponse> updateFarm(
      $pb.ServerContext ctx, $2.UpdateFarmRequest request);
  $async.Future<$2.DeleteFarmResponse> deleteFarm(
      $pb.ServerContext ctx, $2.DeleteFarmRequest request);
  $async.Future<$2.SetFarmBoundaryResponse> setFarmBoundary(
      $pb.ServerContext ctx, $2.SetFarmBoundaryRequest request);
  $async.Future<$2.GetFarmBoundaryResponse> getFarmBoundary(
      $pb.ServerContext ctx, $2.GetFarmBoundaryRequest request);
  $async.Future<$2.TransferOwnershipResponse> transferOwnership(
      $pb.ServerContext ctx, $2.TransferOwnershipRequest request);
  $async.Future<$2.CreateManagementUnitResponse> createManagementUnit(
      $pb.ServerContext ctx, $2.CreateManagementUnitRequest request);
  $async.Future<$2.GetManagementUnitResponse> getManagementUnit(
      $pb.ServerContext ctx, $2.GetManagementUnitRequest request);
  $async.Future<$2.ListManagementUnitsResponse> listManagementUnits(
      $pb.ServerContext ctx, $2.ListManagementUnitsRequest request);
  $async.Future<$2.UpdateManagementUnitResponse> updateManagementUnit(
      $pb.ServerContext ctx, $2.UpdateManagementUnitRequest request);
  $async.Future<$2.DeleteManagementUnitResponse> deleteManagementUnit(
      $pb.ServerContext ctx, $2.DeleteManagementUnitRequest request);
  $async.Future<$2.AssignFieldsToUnitResponse> assignFieldsToUnit(
      $pb.ServerContext ctx, $2.AssignFieldsToUnitRequest request);
  $async.Future<$2.RemoveFieldsFromUnitResponse> removeFieldsFromUnit(
      $pb.ServerContext ctx, $2.RemoveFieldsFromUnitRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'CreateFarm':
        return $2.CreateFarmRequest();
      case 'GetFarm':
        return $2.GetFarmRequest();
      case 'ListFarms':
        return $2.ListFarmsRequest();
      case 'UpdateFarm':
        return $2.UpdateFarmRequest();
      case 'DeleteFarm':
        return $2.DeleteFarmRequest();
      case 'SetFarmBoundary':
        return $2.SetFarmBoundaryRequest();
      case 'GetFarmBoundary':
        return $2.GetFarmBoundaryRequest();
      case 'TransferOwnership':
        return $2.TransferOwnershipRequest();
      case 'CreateManagementUnit':
        return $2.CreateManagementUnitRequest();
      case 'GetManagementUnit':
        return $2.GetManagementUnitRequest();
      case 'ListManagementUnits':
        return $2.ListManagementUnitsRequest();
      case 'UpdateManagementUnit':
        return $2.UpdateManagementUnitRequest();
      case 'DeleteManagementUnit':
        return $2.DeleteManagementUnitRequest();
      case 'AssignFieldsToUnit':
        return $2.AssignFieldsToUnitRequest();
      case 'RemoveFieldsFromUnit':
        return $2.RemoveFieldsFromUnitRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'CreateFarm':
        return createFarm(ctx, request as $2.CreateFarmRequest);
      case 'GetFarm':
        return getFarm(ctx, request as $2.GetFarmRequest);
      case 'ListFarms':
        return listFarms(ctx, request as $2.ListFarmsRequest);
      case 'UpdateFarm':
        return updateFarm(ctx, request as $2.UpdateFarmRequest);
      case 'DeleteFarm':
        return deleteFarm(ctx, request as $2.DeleteFarmRequest);
      case 'SetFarmBoundary':
        return setFarmBoundary(ctx, request as $2.SetFarmBoundaryRequest);
      case 'GetFarmBoundary':
        return getFarmBoundary(ctx, request as $2.GetFarmBoundaryRequest);
      case 'TransferOwnership':
        return transferOwnership(ctx, request as $2.TransferOwnershipRequest);
      case 'CreateManagementUnit':
        return createManagementUnit(
            ctx, request as $2.CreateManagementUnitRequest);
      case 'GetManagementUnit':
        return getManagementUnit(ctx, request as $2.GetManagementUnitRequest);
      case 'ListManagementUnits':
        return listManagementUnits(
            ctx, request as $2.ListManagementUnitsRequest);
      case 'UpdateManagementUnit':
        return updateManagementUnit(
            ctx, request as $2.UpdateManagementUnitRequest);
      case 'DeleteManagementUnit':
        return deleteManagementUnit(
            ctx, request as $2.DeleteManagementUnitRequest);
      case 'AssignFieldsToUnit':
        return assignFieldsToUnit(ctx, request as $2.AssignFieldsToUnitRequest);
      case 'RemoveFieldsFromUnit':
        return removeFieldsFromUnit(
            ctx, request as $2.RemoveFieldsFromUnitRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => FarmServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => FarmServiceBase$messageJson;
}
