// This is a generated file - do not edit.
//
// Generated from device.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart'
    as $0;

import 'device.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'device.pbenum.dart';

/// Device is one piece of field hardware.
class Device extends $pb.GeneratedMessage {
  factory Device({
    $core.String? id,
    $core.String? serial,
    $core.String? name,
    DeviceKind? kind,
    DeviceStatus? status,
    $core.String? farmId,
    $core.String? fieldId,
    $core.String? fleet,
    $core.String? firmwareVersion,
    $core.String? hardwareRevision,
    $core.double? latitude,
    $core.double? longitude,
    $0.Timestamp? provisionedAt,
    $0.Timestamp? lastSeenAt,
    $core.double? batteryPercent,
    $core.int? signalDbm,
    $core.String? fault,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (serial != null) result.serial = serial;
    if (name != null) result.name = name;
    if (kind != null) result.kind = kind;
    if (status != null) result.status = status;
    if (farmId != null) result.farmId = farmId;
    if (fieldId != null) result.fieldId = fieldId;
    if (fleet != null) result.fleet = fleet;
    if (firmwareVersion != null) result.firmwareVersion = firmwareVersion;
    if (hardwareRevision != null) result.hardwareRevision = hardwareRevision;
    if (latitude != null) result.latitude = latitude;
    if (longitude != null) result.longitude = longitude;
    if (provisionedAt != null) result.provisionedAt = provisionedAt;
    if (lastSeenAt != null) result.lastSeenAt = lastSeenAt;
    if (batteryPercent != null) result.batteryPercent = batteryPercent;
    if (signalDbm != null) result.signalDbm = signalDbm;
    if (fault != null) result.fault = fault;
    return result;
  }

  Device._();

  factory Device.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Device.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Device',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.device.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'serial')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aE<DeviceKind>(4, _omitFieldNames ? '' : 'kind',
        enumValues: DeviceKind.values)
    ..aE<DeviceStatus>(5, _omitFieldNames ? '' : 'status',
        enumValues: DeviceStatus.values)
    ..aOS(6, _omitFieldNames ? '' : 'farmId')
    ..aOS(7, _omitFieldNames ? '' : 'fieldId')
    ..aOS(8, _omitFieldNames ? '' : 'fleet')
    ..aOS(9, _omitFieldNames ? '' : 'firmwareVersion')
    ..aOS(10, _omitFieldNames ? '' : 'hardwareRevision')
    ..aD(11, _omitFieldNames ? '' : 'latitude')
    ..aD(12, _omitFieldNames ? '' : 'longitude')
    ..aOM<$0.Timestamp>(13, _omitFieldNames ? '' : 'provisionedAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(14, _omitFieldNames ? '' : 'lastSeenAt',
        subBuilder: $0.Timestamp.create)
    ..aD(15, _omitFieldNames ? '' : 'batteryPercent')
    ..aI(16, _omitFieldNames ? '' : 'signalDbm')
    ..aOS(17, _omitFieldNames ? '' : 'fault')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Device clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Device copyWith(void Function(Device) updates) =>
      super.copyWith((message) => updates(message as Device)) as Device;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Device create() => Device._();
  @$core.override
  Device createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Device getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Device>(create);
  static Device? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get serial => $_getSZ(1);
  @$pb.TagNumber(2)
  set serial($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSerial() => $_has(1);
  @$pb.TagNumber(2)
  void clearSerial() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);

  @$pb.TagNumber(4)
  DeviceKind get kind => $_getN(3);
  @$pb.TagNumber(4)
  set kind(DeviceKind value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasKind() => $_has(3);
  @$pb.TagNumber(4)
  void clearKind() => $_clearField(4);

  @$pb.TagNumber(5)
  DeviceStatus get status => $_getN(4);
  @$pb.TagNumber(5)
  set status(DeviceStatus value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(4);
  @$pb.TagNumber(5)
  void clearStatus() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get farmId => $_getSZ(5);
  @$pb.TagNumber(6)
  set farmId($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasFarmId() => $_has(5);
  @$pb.TagNumber(6)
  void clearFarmId() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get fieldId => $_getSZ(6);
  @$pb.TagNumber(7)
  set fieldId($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasFieldId() => $_has(6);
  @$pb.TagNumber(7)
  void clearFieldId() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get fleet => $_getSZ(7);
  @$pb.TagNumber(8)
  set fleet($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasFleet() => $_has(7);
  @$pb.TagNumber(8)
  void clearFleet() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get firmwareVersion => $_getSZ(8);
  @$pb.TagNumber(9)
  set firmwareVersion($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasFirmwareVersion() => $_has(8);
  @$pb.TagNumber(9)
  void clearFirmwareVersion() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get hardwareRevision => $_getSZ(9);
  @$pb.TagNumber(10)
  set hardwareRevision($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasHardwareRevision() => $_has(9);
  @$pb.TagNumber(10)
  void clearHardwareRevision() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.double get latitude => $_getN(10);
  @$pb.TagNumber(11)
  set latitude($core.double value) => $_setDouble(10, value);
  @$pb.TagNumber(11)
  $core.bool hasLatitude() => $_has(10);
  @$pb.TagNumber(11)
  void clearLatitude() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.double get longitude => $_getN(11);
  @$pb.TagNumber(12)
  set longitude($core.double value) => $_setDouble(11, value);
  @$pb.TagNumber(12)
  $core.bool hasLongitude() => $_has(11);
  @$pb.TagNumber(12)
  void clearLongitude() => $_clearField(12);

  @$pb.TagNumber(13)
  $0.Timestamp get provisionedAt => $_getN(12);
  @$pb.TagNumber(13)
  set provisionedAt($0.Timestamp value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasProvisionedAt() => $_has(12);
  @$pb.TagNumber(13)
  void clearProvisionedAt() => $_clearField(13);
  @$pb.TagNumber(13)
  $0.Timestamp ensureProvisionedAt() => $_ensure(12);

  @$pb.TagNumber(14)
  $0.Timestamp get lastSeenAt => $_getN(13);
  @$pb.TagNumber(14)
  set lastSeenAt($0.Timestamp value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasLastSeenAt() => $_has(13);
  @$pb.TagNumber(14)
  void clearLastSeenAt() => $_clearField(14);
  @$pb.TagNumber(14)
  $0.Timestamp ensureLastSeenAt() => $_ensure(13);

  @$pb.TagNumber(15)
  $core.double get batteryPercent => $_getN(14);
  @$pb.TagNumber(15)
  set batteryPercent($core.double value) => $_setDouble(14, value);
  @$pb.TagNumber(15)
  $core.bool hasBatteryPercent() => $_has(14);
  @$pb.TagNumber(15)
  void clearBatteryPercent() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.int get signalDbm => $_getIZ(15);
  @$pb.TagNumber(16)
  set signalDbm($core.int value) => $_setSignedInt32(15, value);
  @$pb.TagNumber(16)
  $core.bool hasSignalDbm() => $_has(15);
  @$pb.TagNumber(16)
  void clearSignalDbm() => $_clearField(16);

  /// Why the device is DEGRADED, as the device reported it.
  @$pb.TagNumber(17)
  $core.String get fault => $_getSZ(16);
  @$pb.TagNumber(17)
  set fault($core.String value) => $_setString(16, value);
  @$pb.TagNumber(17)
  $core.bool hasFault() => $_has(16);
  @$pb.TagNumber(17)
  void clearFault() => $_clearField(17);
}

/// Heartbeat is one health report from a device.
class Heartbeat extends $pb.GeneratedMessage {
  factory Heartbeat({
    $core.String? deviceId,
    $core.String? firmwareVersion,
    $core.double? batteryPercent,
    $core.int? signalDbm,
    $core.String? fault,
    $0.Timestamp? recordedAt,
  }) {
    final result = create();
    if (deviceId != null) result.deviceId = deviceId;
    if (firmwareVersion != null) result.firmwareVersion = firmwareVersion;
    if (batteryPercent != null) result.batteryPercent = batteryPercent;
    if (signalDbm != null) result.signalDbm = signalDbm;
    if (fault != null) result.fault = fault;
    if (recordedAt != null) result.recordedAt = recordedAt;
    return result;
  }

  Heartbeat._();

  factory Heartbeat.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Heartbeat.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Heartbeat',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.device.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'deviceId')
    ..aOS(2, _omitFieldNames ? '' : 'firmwareVersion')
    ..aD(3, _omitFieldNames ? '' : 'batteryPercent')
    ..aI(4, _omitFieldNames ? '' : 'signalDbm')
    ..aOS(5, _omitFieldNames ? '' : 'fault')
    ..aOM<$0.Timestamp>(6, _omitFieldNames ? '' : 'recordedAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Heartbeat clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Heartbeat copyWith(void Function(Heartbeat) updates) =>
      super.copyWith((message) => updates(message as Heartbeat)) as Heartbeat;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Heartbeat create() => Heartbeat._();
  @$core.override
  Heartbeat createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Heartbeat getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Heartbeat>(create);
  static Heartbeat? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get deviceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set deviceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDeviceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeviceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get firmwareVersion => $_getSZ(1);
  @$pb.TagNumber(2)
  set firmwareVersion($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFirmwareVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearFirmwareVersion() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get batteryPercent => $_getN(2);
  @$pb.TagNumber(3)
  set batteryPercent($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBatteryPercent() => $_has(2);
  @$pb.TagNumber(3)
  void clearBatteryPercent() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get signalDbm => $_getIZ(3);
  @$pb.TagNumber(4)
  set signalDbm($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSignalDbm() => $_has(3);
  @$pb.TagNumber(4)
  void clearSignalDbm() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get fault => $_getSZ(4);
  @$pb.TagNumber(5)
  set fault($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFault() => $_has(4);
  @$pb.TagNumber(5)
  void clearFault() => $_clearField(5);

  /// When the device took the reading, not when it arrived — a gateway buffers
  /// for hours when the uplink is down.
  @$pb.TagNumber(6)
  $0.Timestamp get recordedAt => $_getN(5);
  @$pb.TagNumber(6)
  set recordedAt($0.Timestamp value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasRecordedAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearRecordedAt() => $_clearField(6);
  @$pb.TagNumber(6)
  $0.Timestamp ensureRecordedAt() => $_ensure(5);
}

/// FleetHealth summarises a fleet.
class FleetHealth extends $pb.GeneratedMessage {
  factory FleetHealth({
    $core.String? fleet,
    $core.int? total,
    $core.int? online,
    $core.int? offline,
    $core.int? degraded,
    $core.int? provisioned,
    $core.int? lowBattery,
    $0.Timestamp? computedAt,
  }) {
    final result = create();
    if (fleet != null) result.fleet = fleet;
    if (total != null) result.total = total;
    if (online != null) result.online = online;
    if (offline != null) result.offline = offline;
    if (degraded != null) result.degraded = degraded;
    if (provisioned != null) result.provisioned = provisioned;
    if (lowBattery != null) result.lowBattery = lowBattery;
    if (computedAt != null) result.computedAt = computedAt;
    return result;
  }

  FleetHealth._();

  factory FleetHealth.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FleetHealth.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FleetHealth',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.device.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fleet')
    ..aI(2, _omitFieldNames ? '' : 'total')
    ..aI(3, _omitFieldNames ? '' : 'online')
    ..aI(4, _omitFieldNames ? '' : 'offline')
    ..aI(5, _omitFieldNames ? '' : 'degraded')
    ..aI(6, _omitFieldNames ? '' : 'provisioned')
    ..aI(7, _omitFieldNames ? '' : 'lowBattery')
    ..aOM<$0.Timestamp>(8, _omitFieldNames ? '' : 'computedAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FleetHealth clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FleetHealth copyWith(void Function(FleetHealth) updates) =>
      super.copyWith((message) => updates(message as FleetHealth))
          as FleetHealth;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FleetHealth create() => FleetHealth._();
  @$core.override
  FleetHealth createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FleetHealth getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FleetHealth>(create);
  static FleetHealth? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fleet => $_getSZ(0);
  @$pb.TagNumber(1)
  set fleet($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFleet() => $_has(0);
  @$pb.TagNumber(1)
  void clearFleet() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get total => $_getIZ(1);
  @$pb.TagNumber(2)
  set total($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotal() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotal() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get online => $_getIZ(2);
  @$pb.TagNumber(3)
  set online($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOnline() => $_has(2);
  @$pb.TagNumber(3)
  void clearOnline() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get offline => $_getIZ(3);
  @$pb.TagNumber(4)
  set offline($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasOffline() => $_has(3);
  @$pb.TagNumber(4)
  void clearOffline() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get degraded => $_getIZ(4);
  @$pb.TagNumber(5)
  set degraded($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDegraded() => $_has(4);
  @$pb.TagNumber(5)
  void clearDegraded() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get provisioned => $_getIZ(5);
  @$pb.TagNumber(6)
  set provisioned($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasProvisioned() => $_has(5);
  @$pb.TagNumber(6)
  void clearProvisioned() => $_clearField(6);

  /// Devices below the low-battery threshold, which is what decides whether a
  /// visit is needed before the next season rather than after it.
  @$pb.TagNumber(7)
  $core.int get lowBattery => $_getIZ(6);
  @$pb.TagNumber(7)
  set lowBattery($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasLowBattery() => $_has(6);
  @$pb.TagNumber(7)
  void clearLowBattery() => $_clearField(7);

  @$pb.TagNumber(8)
  $0.Timestamp get computedAt => $_getN(7);
  @$pb.TagNumber(8)
  set computedAt($0.Timestamp value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasComputedAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearComputedAt() => $_clearField(8);
  @$pb.TagNumber(8)
  $0.Timestamp ensureComputedAt() => $_ensure(7);
}

/// FirmwareRollout is a staged update across a fleet.
class FirmwareRollout extends $pb.GeneratedMessage {
  factory FirmwareRollout({
    $core.String? id,
    $core.String? fleet,
    DeviceKind? kind,
    $core.String? version,
    $core.String? artifactUrl,
    $core.String? artifactSha256,
    RolloutState? state,
    $core.int? stagePercent,
    $core.double? failureThreshold,
    $core.int? offered,
    $core.int? succeeded,
    $core.int? failed,
    $0.Timestamp? createdAt,
    $core.String? haltedReason,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (fleet != null) result.fleet = fleet;
    if (kind != null) result.kind = kind;
    if (version != null) result.version = version;
    if (artifactUrl != null) result.artifactUrl = artifactUrl;
    if (artifactSha256 != null) result.artifactSha256 = artifactSha256;
    if (state != null) result.state = state;
    if (stagePercent != null) result.stagePercent = stagePercent;
    if (failureThreshold != null) result.failureThreshold = failureThreshold;
    if (offered != null) result.offered = offered;
    if (succeeded != null) result.succeeded = succeeded;
    if (failed != null) result.failed = failed;
    if (createdAt != null) result.createdAt = createdAt;
    if (haltedReason != null) result.haltedReason = haltedReason;
    return result;
  }

  FirmwareRollout._();

  factory FirmwareRollout.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FirmwareRollout.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FirmwareRollout',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.device.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'fleet')
    ..aE<DeviceKind>(3, _omitFieldNames ? '' : 'kind',
        enumValues: DeviceKind.values)
    ..aOS(4, _omitFieldNames ? '' : 'version')
    ..aOS(5, _omitFieldNames ? '' : 'artifactUrl')
    ..aOS(6, _omitFieldNames ? '' : 'artifactSha256')
    ..aE<RolloutState>(7, _omitFieldNames ? '' : 'state',
        enumValues: RolloutState.values)
    ..aI(8, _omitFieldNames ? '' : 'stagePercent')
    ..aD(9, _omitFieldNames ? '' : 'failureThreshold')
    ..aI(10, _omitFieldNames ? '' : 'offered')
    ..aI(11, _omitFieldNames ? '' : 'succeeded')
    ..aI(12, _omitFieldNames ? '' : 'failed')
    ..aOM<$0.Timestamp>(13, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOS(14, _omitFieldNames ? '' : 'haltedReason')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FirmwareRollout clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FirmwareRollout copyWith(void Function(FirmwareRollout) updates) =>
      super.copyWith((message) => updates(message as FirmwareRollout))
          as FirmwareRollout;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FirmwareRollout create() => FirmwareRollout._();
  @$core.override
  FirmwareRollout createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FirmwareRollout getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FirmwareRollout>(create);
  static FirmwareRollout? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get fleet => $_getSZ(1);
  @$pb.TagNumber(2)
  set fleet($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFleet() => $_has(1);
  @$pb.TagNumber(2)
  void clearFleet() => $_clearField(2);

  @$pb.TagNumber(3)
  DeviceKind get kind => $_getN(2);
  @$pb.TagNumber(3)
  set kind(DeviceKind value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasKind() => $_has(2);
  @$pb.TagNumber(3)
  void clearKind() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get version => $_getSZ(3);
  @$pb.TagNumber(4)
  set version($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasVersion() => $_has(3);
  @$pb.TagNumber(4)
  void clearVersion() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get artifactUrl => $_getSZ(4);
  @$pb.TagNumber(5)
  set artifactUrl($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasArtifactUrl() => $_has(4);
  @$pb.TagNumber(5)
  void clearArtifactUrl() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get artifactSha256 => $_getSZ(5);
  @$pb.TagNumber(6)
  set artifactSha256($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasArtifactSha256() => $_has(5);
  @$pb.TagNumber(6)
  void clearArtifactSha256() => $_clearField(6);

  @$pb.TagNumber(7)
  RolloutState get state => $_getN(6);
  @$pb.TagNumber(7)
  set state(RolloutState value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasState() => $_has(6);
  @$pb.TagNumber(7)
  void clearState() => $_clearField(7);

  /// Percentage of the fleet the rollout is allowed to reach so far. Staged
  /// rather than all-at-once: bad firmware on every device in a region at the
  /// same time is a season lost, and every one of them needs a physical visit.
  @$pb.TagNumber(8)
  $core.int get stagePercent => $_getIZ(7);
  @$pb.TagNumber(8)
  set stagePercent($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasStagePercent() => $_has(7);
  @$pb.TagNumber(8)
  void clearStagePercent() => $_clearField(8);

  /// The rollout halts when this share of attempts fail.
  @$pb.TagNumber(9)
  $core.double get failureThreshold => $_getN(8);
  @$pb.TagNumber(9)
  set failureThreshold($core.double value) => $_setDouble(8, value);
  @$pb.TagNumber(9)
  $core.bool hasFailureThreshold() => $_has(8);
  @$pb.TagNumber(9)
  void clearFailureThreshold() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.int get offered => $_getIZ(9);
  @$pb.TagNumber(10)
  set offered($core.int value) => $_setSignedInt32(9, value);
  @$pb.TagNumber(10)
  $core.bool hasOffered() => $_has(9);
  @$pb.TagNumber(10)
  void clearOffered() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.int get succeeded => $_getIZ(10);
  @$pb.TagNumber(11)
  set succeeded($core.int value) => $_setSignedInt32(10, value);
  @$pb.TagNumber(11)
  $core.bool hasSucceeded() => $_has(10);
  @$pb.TagNumber(11)
  void clearSucceeded() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.int get failed => $_getIZ(11);
  @$pb.TagNumber(12)
  set failed($core.int value) => $_setSignedInt32(11, value);
  @$pb.TagNumber(12)
  $core.bool hasFailed() => $_has(11);
  @$pb.TagNumber(12)
  void clearFailed() => $_clearField(12);

  @$pb.TagNumber(13)
  $0.Timestamp get createdAt => $_getN(12);
  @$pb.TagNumber(13)
  set createdAt($0.Timestamp value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasCreatedAt() => $_has(12);
  @$pb.TagNumber(13)
  void clearCreatedAt() => $_clearField(13);
  @$pb.TagNumber(13)
  $0.Timestamp ensureCreatedAt() => $_ensure(12);

  @$pb.TagNumber(14)
  $core.String get haltedReason => $_getSZ(13);
  @$pb.TagNumber(14)
  set haltedReason($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasHaltedReason() => $_has(13);
  @$pb.TagNumber(14)
  void clearHaltedReason() => $_clearField(14);
}

/// DeviceUpdate is one device's progress through a rollout.
class DeviceUpdate extends $pb.GeneratedMessage {
  factory DeviceUpdate({
    $core.String? deviceId,
    $core.String? rolloutId,
    UpdateState? state,
    $core.String? detail,
    $0.Timestamp? updatedAt,
  }) {
    final result = create();
    if (deviceId != null) result.deviceId = deviceId;
    if (rolloutId != null) result.rolloutId = rolloutId;
    if (state != null) result.state = state;
    if (detail != null) result.detail = detail;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  DeviceUpdate._();

  factory DeviceUpdate.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeviceUpdate.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeviceUpdate',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.device.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'deviceId')
    ..aOS(2, _omitFieldNames ? '' : 'rolloutId')
    ..aE<UpdateState>(3, _omitFieldNames ? '' : 'state',
        enumValues: UpdateState.values)
    ..aOS(4, _omitFieldNames ? '' : 'detail')
    ..aOM<$0.Timestamp>(5, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeviceUpdate clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeviceUpdate copyWith(void Function(DeviceUpdate) updates) =>
      super.copyWith((message) => updates(message as DeviceUpdate))
          as DeviceUpdate;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeviceUpdate create() => DeviceUpdate._();
  @$core.override
  DeviceUpdate createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeviceUpdate getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeviceUpdate>(create);
  static DeviceUpdate? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get deviceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set deviceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDeviceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeviceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get rolloutId => $_getSZ(1);
  @$pb.TagNumber(2)
  set rolloutId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRolloutId() => $_has(1);
  @$pb.TagNumber(2)
  void clearRolloutId() => $_clearField(2);

  @$pb.TagNumber(3)
  UpdateState get state => $_getN(2);
  @$pb.TagNumber(3)
  set state(UpdateState value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasState() => $_has(2);
  @$pb.TagNumber(3)
  void clearState() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get detail => $_getSZ(3);
  @$pb.TagNumber(4)
  set detail($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDetail() => $_has(3);
  @$pb.TagNumber(4)
  void clearDetail() => $_clearField(4);

  @$pb.TagNumber(5)
  $0.Timestamp get updatedAt => $_getN(4);
  @$pb.TagNumber(5)
  set updatedAt($0.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasUpdatedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearUpdatedAt() => $_clearField(5);
  @$pb.TagNumber(5)
  $0.Timestamp ensureUpdatedAt() => $_ensure(4);
}

class ProvisionDeviceRequest extends $pb.GeneratedMessage {
  factory ProvisionDeviceRequest({
    $core.String? serial,
    $core.String? name,
    DeviceKind? kind,
    $core.String? farmId,
    $core.String? fieldId,
    $core.String? fleet,
    $core.String? hardwareRevision,
    $core.double? latitude,
    $core.double? longitude,
  }) {
    final result = create();
    if (serial != null) result.serial = serial;
    if (name != null) result.name = name;
    if (kind != null) result.kind = kind;
    if (farmId != null) result.farmId = farmId;
    if (fieldId != null) result.fieldId = fieldId;
    if (fleet != null) result.fleet = fleet;
    if (hardwareRevision != null) result.hardwareRevision = hardwareRevision;
    if (latitude != null) result.latitude = latitude;
    if (longitude != null) result.longitude = longitude;
    return result;
  }

  ProvisionDeviceRequest._();

  factory ProvisionDeviceRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ProvisionDeviceRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProvisionDeviceRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.device.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'serial')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aE<DeviceKind>(3, _omitFieldNames ? '' : 'kind',
        enumValues: DeviceKind.values)
    ..aOS(4, _omitFieldNames ? '' : 'farmId')
    ..aOS(5, _omitFieldNames ? '' : 'fieldId')
    ..aOS(6, _omitFieldNames ? '' : 'fleet')
    ..aOS(7, _omitFieldNames ? '' : 'hardwareRevision')
    ..aD(8, _omitFieldNames ? '' : 'latitude')
    ..aD(9, _omitFieldNames ? '' : 'longitude')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProvisionDeviceRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProvisionDeviceRequest copyWith(
          void Function(ProvisionDeviceRequest) updates) =>
      super.copyWith((message) => updates(message as ProvisionDeviceRequest))
          as ProvisionDeviceRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ProvisionDeviceRequest create() => ProvisionDeviceRequest._();
  @$core.override
  ProvisionDeviceRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ProvisionDeviceRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ProvisionDeviceRequest>(create);
  static ProvisionDeviceRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get serial => $_getSZ(0);
  @$pb.TagNumber(1)
  set serial($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSerial() => $_has(0);
  @$pb.TagNumber(1)
  void clearSerial() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  DeviceKind get kind => $_getN(2);
  @$pb.TagNumber(3)
  set kind(DeviceKind value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasKind() => $_has(2);
  @$pb.TagNumber(3)
  void clearKind() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get farmId => $_getSZ(3);
  @$pb.TagNumber(4)
  set farmId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFarmId() => $_has(3);
  @$pb.TagNumber(4)
  void clearFarmId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get fieldId => $_getSZ(4);
  @$pb.TagNumber(5)
  set fieldId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFieldId() => $_has(4);
  @$pb.TagNumber(5)
  void clearFieldId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get fleet => $_getSZ(5);
  @$pb.TagNumber(6)
  set fleet($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasFleet() => $_has(5);
  @$pb.TagNumber(6)
  void clearFleet() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get hardwareRevision => $_getSZ(6);
  @$pb.TagNumber(7)
  set hardwareRevision($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasHardwareRevision() => $_has(6);
  @$pb.TagNumber(7)
  void clearHardwareRevision() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get latitude => $_getN(7);
  @$pb.TagNumber(8)
  set latitude($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasLatitude() => $_has(7);
  @$pb.TagNumber(8)
  void clearLatitude() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.double get longitude => $_getN(8);
  @$pb.TagNumber(9)
  set longitude($core.double value) => $_setDouble(8, value);
  @$pb.TagNumber(9)
  $core.bool hasLongitude() => $_has(8);
  @$pb.TagNumber(9)
  void clearLongitude() => $_clearField(9);
}

class ProvisionDeviceResponse extends $pb.GeneratedMessage {
  factory ProvisionDeviceResponse({
    Device? device,
    $core.String? enrolmentToken,
  }) {
    final result = create();
    if (device != null) result.device = device;
    if (enrolmentToken != null) result.enrolmentToken = enrolmentToken;
    return result;
  }

  ProvisionDeviceResponse._();

  factory ProvisionDeviceResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ProvisionDeviceResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProvisionDeviceResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.device.v1'),
      createEmptyInstance: create)
    ..aOM<Device>(1, _omitFieldNames ? '' : 'device', subBuilder: Device.create)
    ..aOS(2, _omitFieldNames ? '' : 'enrolmentToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProvisionDeviceResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProvisionDeviceResponse copyWith(
          void Function(ProvisionDeviceResponse) updates) =>
      super.copyWith((message) => updates(message as ProvisionDeviceResponse))
          as ProvisionDeviceResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ProvisionDeviceResponse create() => ProvisionDeviceResponse._();
  @$core.override
  ProvisionDeviceResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ProvisionDeviceResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ProvisionDeviceResponse>(create);
  static ProvisionDeviceResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Device get device => $_getN(0);
  @$pb.TagNumber(1)
  set device(Device value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasDevice() => $_has(0);
  @$pb.TagNumber(1)
  void clearDevice() => $_clearField(1);
  @$pb.TagNumber(1)
  Device ensureDevice() => $_ensure(0);

  /// The credential the device authenticates with. Returned once, at
  /// provisioning, and never readable again.
  @$pb.TagNumber(2)
  $core.String get enrolmentToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set enrolmentToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEnrolmentToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearEnrolmentToken() => $_clearField(2);
}

class GetDeviceRequest extends $pb.GeneratedMessage {
  factory GetDeviceRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  GetDeviceRequest._();

  factory GetDeviceRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetDeviceRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetDeviceRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.device.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDeviceRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDeviceRequest copyWith(void Function(GetDeviceRequest) updates) =>
      super.copyWith((message) => updates(message as GetDeviceRequest))
          as GetDeviceRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetDeviceRequest create() => GetDeviceRequest._();
  @$core.override
  GetDeviceRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetDeviceRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetDeviceRequest>(create);
  static GetDeviceRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class GetDeviceResponse extends $pb.GeneratedMessage {
  factory GetDeviceResponse({
    Device? device,
  }) {
    final result = create();
    if (device != null) result.device = device;
    return result;
  }

  GetDeviceResponse._();

  factory GetDeviceResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetDeviceResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetDeviceResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.device.v1'),
      createEmptyInstance: create)
    ..aOM<Device>(1, _omitFieldNames ? '' : 'device', subBuilder: Device.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDeviceResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDeviceResponse copyWith(void Function(GetDeviceResponse) updates) =>
      super.copyWith((message) => updates(message as GetDeviceResponse))
          as GetDeviceResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetDeviceResponse create() => GetDeviceResponse._();
  @$core.override
  GetDeviceResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetDeviceResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetDeviceResponse>(create);
  static GetDeviceResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Device get device => $_getN(0);
  @$pb.TagNumber(1)
  set device(Device value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasDevice() => $_has(0);
  @$pb.TagNumber(1)
  void clearDevice() => $_clearField(1);
  @$pb.TagNumber(1)
  Device ensureDevice() => $_ensure(0);
}

class ListDevicesRequest extends $pb.GeneratedMessage {
  factory ListDevicesRequest({
    $core.String? fleet,
    $core.String? farmId,
    $core.String? fieldId,
    DeviceKind? kind,
    DeviceStatus? status,
    $core.int? pageSize,
    $core.String? pageToken,
  }) {
    final result = create();
    if (fleet != null) result.fleet = fleet;
    if (farmId != null) result.farmId = farmId;
    if (fieldId != null) result.fieldId = fieldId;
    if (kind != null) result.kind = kind;
    if (status != null) result.status = status;
    if (pageSize != null) result.pageSize = pageSize;
    if (pageToken != null) result.pageToken = pageToken;
    return result;
  }

  ListDevicesRequest._();

  factory ListDevicesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListDevicesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListDevicesRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.device.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fleet')
    ..aOS(2, _omitFieldNames ? '' : 'farmId')
    ..aOS(3, _omitFieldNames ? '' : 'fieldId')
    ..aE<DeviceKind>(4, _omitFieldNames ? '' : 'kind',
        enumValues: DeviceKind.values)
    ..aE<DeviceStatus>(5, _omitFieldNames ? '' : 'status',
        enumValues: DeviceStatus.values)
    ..aI(6, _omitFieldNames ? '' : 'pageSize')
    ..aOS(7, _omitFieldNames ? '' : 'pageToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListDevicesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListDevicesRequest copyWith(void Function(ListDevicesRequest) updates) =>
      super.copyWith((message) => updates(message as ListDevicesRequest))
          as ListDevicesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListDevicesRequest create() => ListDevicesRequest._();
  @$core.override
  ListDevicesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListDevicesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListDevicesRequest>(create);
  static ListDevicesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fleet => $_getSZ(0);
  @$pb.TagNumber(1)
  set fleet($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFleet() => $_has(0);
  @$pb.TagNumber(1)
  void clearFleet() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get farmId => $_getSZ(1);
  @$pb.TagNumber(2)
  set farmId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFarmId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFarmId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get fieldId => $_getSZ(2);
  @$pb.TagNumber(3)
  set fieldId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFieldId() => $_has(2);
  @$pb.TagNumber(3)
  void clearFieldId() => $_clearField(3);

  @$pb.TagNumber(4)
  DeviceKind get kind => $_getN(3);
  @$pb.TagNumber(4)
  set kind(DeviceKind value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasKind() => $_has(3);
  @$pb.TagNumber(4)
  void clearKind() => $_clearField(4);

  @$pb.TagNumber(5)
  DeviceStatus get status => $_getN(4);
  @$pb.TagNumber(5)
  set status(DeviceStatus value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(4);
  @$pb.TagNumber(5)
  void clearStatus() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get pageSize => $_getIZ(5);
  @$pb.TagNumber(6)
  set pageSize($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPageSize() => $_has(5);
  @$pb.TagNumber(6)
  void clearPageSize() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get pageToken => $_getSZ(6);
  @$pb.TagNumber(7)
  set pageToken($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasPageToken() => $_has(6);
  @$pb.TagNumber(7)
  void clearPageToken() => $_clearField(7);
}

class ListDevicesResponse extends $pb.GeneratedMessage {
  factory ListDevicesResponse({
    $core.Iterable<Device>? devices,
    $core.String? nextPageToken,
    $core.int? totalCount,
  }) {
    final result = create();
    if (devices != null) result.devices.addAll(devices);
    if (nextPageToken != null) result.nextPageToken = nextPageToken;
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListDevicesResponse._();

  factory ListDevicesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListDevicesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListDevicesResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.device.v1'),
      createEmptyInstance: create)
    ..pPM<Device>(1, _omitFieldNames ? '' : 'devices',
        subBuilder: Device.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextPageToken')
    ..aI(3, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListDevicesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListDevicesResponse copyWith(void Function(ListDevicesResponse) updates) =>
      super.copyWith((message) => updates(message as ListDevicesResponse))
          as ListDevicesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListDevicesResponse create() => ListDevicesResponse._();
  @$core.override
  ListDevicesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListDevicesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListDevicesResponse>(create);
  static ListDevicesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Device> get devices => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get nextPageToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set nextPageToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNextPageToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextPageToken() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get totalCount => $_getIZ(2);
  @$pb.TagNumber(3)
  set totalCount($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTotalCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearTotalCount() => $_clearField(3);
}

class RecordHeartbeatsRequest extends $pb.GeneratedMessage {
  factory RecordHeartbeatsRequest({
    $core.Iterable<Heartbeat>? heartbeats,
  }) {
    final result = create();
    if (heartbeats != null) result.heartbeats.addAll(heartbeats);
    return result;
  }

  RecordHeartbeatsRequest._();

  factory RecordHeartbeatsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RecordHeartbeatsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RecordHeartbeatsRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.device.v1'),
      createEmptyInstance: create)
    ..pPM<Heartbeat>(1, _omitFieldNames ? '' : 'heartbeats',
        subBuilder: Heartbeat.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecordHeartbeatsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecordHeartbeatsRequest copyWith(
          void Function(RecordHeartbeatsRequest) updates) =>
      super.copyWith((message) => updates(message as RecordHeartbeatsRequest))
          as RecordHeartbeatsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RecordHeartbeatsRequest create() => RecordHeartbeatsRequest._();
  @$core.override
  RecordHeartbeatsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RecordHeartbeatsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RecordHeartbeatsRequest>(create);
  static RecordHeartbeatsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Heartbeat> get heartbeats => $_getList(0);
}

class RecordHeartbeatsResponse extends $pb.GeneratedMessage {
  factory RecordHeartbeatsResponse({
    $core.int? recorded,
    $core.Iterable<$core.String>? rejected,
  }) {
    final result = create();
    if (recorded != null) result.recorded = recorded;
    if (rejected != null) result.rejected.addAll(rejected);
    return result;
  }

  RecordHeartbeatsResponse._();

  factory RecordHeartbeatsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RecordHeartbeatsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RecordHeartbeatsResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.device.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'recorded')
    ..pPS(2, _omitFieldNames ? '' : 'rejected')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecordHeartbeatsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecordHeartbeatsResponse copyWith(
          void Function(RecordHeartbeatsResponse) updates) =>
      super.copyWith((message) => updates(message as RecordHeartbeatsResponse))
          as RecordHeartbeatsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RecordHeartbeatsResponse create() => RecordHeartbeatsResponse._();
  @$core.override
  RecordHeartbeatsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RecordHeartbeatsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RecordHeartbeatsResponse>(create);
  static RecordHeartbeatsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get recorded => $_getIZ(0);
  @$pb.TagNumber(1)
  set recorded($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRecorded() => $_has(0);
  @$pb.TagNumber(1)
  void clearRecorded() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get rejected => $_getList(1);
}

class RetireDeviceRequest extends $pb.GeneratedMessage {
  factory RetireDeviceRequest({
    $core.String? id,
    $core.String? reason,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (reason != null) result.reason = reason;
    return result;
  }

  RetireDeviceRequest._();

  factory RetireDeviceRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RetireDeviceRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RetireDeviceRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.device.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RetireDeviceRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RetireDeviceRequest copyWith(void Function(RetireDeviceRequest) updates) =>
      super.copyWith((message) => updates(message as RetireDeviceRequest))
          as RetireDeviceRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RetireDeviceRequest create() => RetireDeviceRequest._();
  @$core.override
  RetireDeviceRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RetireDeviceRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RetireDeviceRequest>(create);
  static RetireDeviceRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get reason => $_getSZ(1);
  @$pb.TagNumber(2)
  set reason($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasReason() => $_has(1);
  @$pb.TagNumber(2)
  void clearReason() => $_clearField(2);
}

class RetireDeviceResponse extends $pb.GeneratedMessage {
  factory RetireDeviceResponse({
    Device? device,
  }) {
    final result = create();
    if (device != null) result.device = device;
    return result;
  }

  RetireDeviceResponse._();

  factory RetireDeviceResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RetireDeviceResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RetireDeviceResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.device.v1'),
      createEmptyInstance: create)
    ..aOM<Device>(1, _omitFieldNames ? '' : 'device', subBuilder: Device.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RetireDeviceResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RetireDeviceResponse copyWith(void Function(RetireDeviceResponse) updates) =>
      super.copyWith((message) => updates(message as RetireDeviceResponse))
          as RetireDeviceResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RetireDeviceResponse create() => RetireDeviceResponse._();
  @$core.override
  RetireDeviceResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RetireDeviceResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RetireDeviceResponse>(create);
  static RetireDeviceResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Device get device => $_getN(0);
  @$pb.TagNumber(1)
  set device(Device value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasDevice() => $_has(0);
  @$pb.TagNumber(1)
  void clearDevice() => $_clearField(1);
  @$pb.TagNumber(1)
  Device ensureDevice() => $_ensure(0);
}

class GetFleetHealthRequest extends $pb.GeneratedMessage {
  factory GetFleetHealthRequest({
    $core.String? fleet,
  }) {
    final result = create();
    if (fleet != null) result.fleet = fleet;
    return result;
  }

  GetFleetHealthRequest._();

  factory GetFleetHealthRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetFleetHealthRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetFleetHealthRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.device.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fleet')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFleetHealthRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFleetHealthRequest copyWith(
          void Function(GetFleetHealthRequest) updates) =>
      super.copyWith((message) => updates(message as GetFleetHealthRequest))
          as GetFleetHealthRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFleetHealthRequest create() => GetFleetHealthRequest._();
  @$core.override
  GetFleetHealthRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetFleetHealthRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetFleetHealthRequest>(create);
  static GetFleetHealthRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fleet => $_getSZ(0);
  @$pb.TagNumber(1)
  set fleet($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFleet() => $_has(0);
  @$pb.TagNumber(1)
  void clearFleet() => $_clearField(1);
}

class GetFleetHealthResponse extends $pb.GeneratedMessage {
  factory GetFleetHealthResponse({
    FleetHealth? health,
  }) {
    final result = create();
    if (health != null) result.health = health;
    return result;
  }

  GetFleetHealthResponse._();

  factory GetFleetHealthResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetFleetHealthResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetFleetHealthResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.device.v1'),
      createEmptyInstance: create)
    ..aOM<FleetHealth>(1, _omitFieldNames ? '' : 'health',
        subBuilder: FleetHealth.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFleetHealthResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFleetHealthResponse copyWith(
          void Function(GetFleetHealthResponse) updates) =>
      super.copyWith((message) => updates(message as GetFleetHealthResponse))
          as GetFleetHealthResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFleetHealthResponse create() => GetFleetHealthResponse._();
  @$core.override
  GetFleetHealthResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetFleetHealthResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetFleetHealthResponse>(create);
  static GetFleetHealthResponse? _defaultInstance;

  @$pb.TagNumber(1)
  FleetHealth get health => $_getN(0);
  @$pb.TagNumber(1)
  set health(FleetHealth value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasHealth() => $_has(0);
  @$pb.TagNumber(1)
  void clearHealth() => $_clearField(1);
  @$pb.TagNumber(1)
  FleetHealth ensureHealth() => $_ensure(0);
}

class CreateRolloutRequest extends $pb.GeneratedMessage {
  factory CreateRolloutRequest({
    $core.String? fleet,
    DeviceKind? kind,
    $core.String? version,
    $core.String? artifactUrl,
    $core.String? artifactSha256,
    $core.int? stagePercent,
    $core.double? failureThreshold,
  }) {
    final result = create();
    if (fleet != null) result.fleet = fleet;
    if (kind != null) result.kind = kind;
    if (version != null) result.version = version;
    if (artifactUrl != null) result.artifactUrl = artifactUrl;
    if (artifactSha256 != null) result.artifactSha256 = artifactSha256;
    if (stagePercent != null) result.stagePercent = stagePercent;
    if (failureThreshold != null) result.failureThreshold = failureThreshold;
    return result;
  }

  CreateRolloutRequest._();

  factory CreateRolloutRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateRolloutRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateRolloutRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.device.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fleet')
    ..aE<DeviceKind>(2, _omitFieldNames ? '' : 'kind',
        enumValues: DeviceKind.values)
    ..aOS(3, _omitFieldNames ? '' : 'version')
    ..aOS(4, _omitFieldNames ? '' : 'artifactUrl')
    ..aOS(5, _omitFieldNames ? '' : 'artifactSha256')
    ..aI(6, _omitFieldNames ? '' : 'stagePercent')
    ..aD(7, _omitFieldNames ? '' : 'failureThreshold')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateRolloutRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateRolloutRequest copyWith(void Function(CreateRolloutRequest) updates) =>
      super.copyWith((message) => updates(message as CreateRolloutRequest))
          as CreateRolloutRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateRolloutRequest create() => CreateRolloutRequest._();
  @$core.override
  CreateRolloutRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateRolloutRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateRolloutRequest>(create);
  static CreateRolloutRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fleet => $_getSZ(0);
  @$pb.TagNumber(1)
  set fleet($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFleet() => $_has(0);
  @$pb.TagNumber(1)
  void clearFleet() => $_clearField(1);

  @$pb.TagNumber(2)
  DeviceKind get kind => $_getN(1);
  @$pb.TagNumber(2)
  set kind(DeviceKind value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasKind() => $_has(1);
  @$pb.TagNumber(2)
  void clearKind() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get version => $_getSZ(2);
  @$pb.TagNumber(3)
  set version($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasVersion() => $_has(2);
  @$pb.TagNumber(3)
  void clearVersion() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get artifactUrl => $_getSZ(3);
  @$pb.TagNumber(4)
  set artifactUrl($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasArtifactUrl() => $_has(3);
  @$pb.TagNumber(4)
  void clearArtifactUrl() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get artifactSha256 => $_getSZ(4);
  @$pb.TagNumber(5)
  set artifactSha256($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasArtifactSha256() => $_has(4);
  @$pb.TagNumber(5)
  void clearArtifactSha256() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get stagePercent => $_getIZ(5);
  @$pb.TagNumber(6)
  set stagePercent($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasStagePercent() => $_has(5);
  @$pb.TagNumber(6)
  void clearStagePercent() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get failureThreshold => $_getN(6);
  @$pb.TagNumber(7)
  set failureThreshold($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasFailureThreshold() => $_has(6);
  @$pb.TagNumber(7)
  void clearFailureThreshold() => $_clearField(7);
}

class CreateRolloutResponse extends $pb.GeneratedMessage {
  factory CreateRolloutResponse({
    FirmwareRollout? rollout,
  }) {
    final result = create();
    if (rollout != null) result.rollout = rollout;
    return result;
  }

  CreateRolloutResponse._();

  factory CreateRolloutResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateRolloutResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateRolloutResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.device.v1'),
      createEmptyInstance: create)
    ..aOM<FirmwareRollout>(1, _omitFieldNames ? '' : 'rollout',
        subBuilder: FirmwareRollout.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateRolloutResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateRolloutResponse copyWith(
          void Function(CreateRolloutResponse) updates) =>
      super.copyWith((message) => updates(message as CreateRolloutResponse))
          as CreateRolloutResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateRolloutResponse create() => CreateRolloutResponse._();
  @$core.override
  CreateRolloutResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateRolloutResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateRolloutResponse>(create);
  static CreateRolloutResponse? _defaultInstance;

  @$pb.TagNumber(1)
  FirmwareRollout get rollout => $_getN(0);
  @$pb.TagNumber(1)
  set rollout(FirmwareRollout value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasRollout() => $_has(0);
  @$pb.TagNumber(1)
  void clearRollout() => $_clearField(1);
  @$pb.TagNumber(1)
  FirmwareRollout ensureRollout() => $_ensure(0);
}

class AdvanceRolloutRequest extends $pb.GeneratedMessage {
  factory AdvanceRolloutRequest({
    $core.String? id,
    $core.int? stagePercent,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (stagePercent != null) result.stagePercent = stagePercent;
    return result;
  }

  AdvanceRolloutRequest._();

  factory AdvanceRolloutRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AdvanceRolloutRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AdvanceRolloutRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.device.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aI(2, _omitFieldNames ? '' : 'stagePercent')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AdvanceRolloutRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AdvanceRolloutRequest copyWith(
          void Function(AdvanceRolloutRequest) updates) =>
      super.copyWith((message) => updates(message as AdvanceRolloutRequest))
          as AdvanceRolloutRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AdvanceRolloutRequest create() => AdvanceRolloutRequest._();
  @$core.override
  AdvanceRolloutRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AdvanceRolloutRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AdvanceRolloutRequest>(create);
  static AdvanceRolloutRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get stagePercent => $_getIZ(1);
  @$pb.TagNumber(2)
  set stagePercent($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStagePercent() => $_has(1);
  @$pb.TagNumber(2)
  void clearStagePercent() => $_clearField(2);
}

class AdvanceRolloutResponse extends $pb.GeneratedMessage {
  factory AdvanceRolloutResponse({
    FirmwareRollout? rollout,
  }) {
    final result = create();
    if (rollout != null) result.rollout = rollout;
    return result;
  }

  AdvanceRolloutResponse._();

  factory AdvanceRolloutResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AdvanceRolloutResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AdvanceRolloutResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.device.v1'),
      createEmptyInstance: create)
    ..aOM<FirmwareRollout>(1, _omitFieldNames ? '' : 'rollout',
        subBuilder: FirmwareRollout.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AdvanceRolloutResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AdvanceRolloutResponse copyWith(
          void Function(AdvanceRolloutResponse) updates) =>
      super.copyWith((message) => updates(message as AdvanceRolloutResponse))
          as AdvanceRolloutResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AdvanceRolloutResponse create() => AdvanceRolloutResponse._();
  @$core.override
  AdvanceRolloutResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AdvanceRolloutResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AdvanceRolloutResponse>(create);
  static AdvanceRolloutResponse? _defaultInstance;

  @$pb.TagNumber(1)
  FirmwareRollout get rollout => $_getN(0);
  @$pb.TagNumber(1)
  set rollout(FirmwareRollout value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasRollout() => $_has(0);
  @$pb.TagNumber(1)
  void clearRollout() => $_clearField(1);
  @$pb.TagNumber(1)
  FirmwareRollout ensureRollout() => $_ensure(0);
}

class ReportUpdateRequest extends $pb.GeneratedMessage {
  factory ReportUpdateRequest({
    $core.String? deviceId,
    $core.String? rolloutId,
    UpdateState? state,
    $core.String? detail,
  }) {
    final result = create();
    if (deviceId != null) result.deviceId = deviceId;
    if (rolloutId != null) result.rolloutId = rolloutId;
    if (state != null) result.state = state;
    if (detail != null) result.detail = detail;
    return result;
  }

  ReportUpdateRequest._();

  factory ReportUpdateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ReportUpdateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReportUpdateRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.device.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'deviceId')
    ..aOS(2, _omitFieldNames ? '' : 'rolloutId')
    ..aE<UpdateState>(3, _omitFieldNames ? '' : 'state',
        enumValues: UpdateState.values)
    ..aOS(4, _omitFieldNames ? '' : 'detail')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReportUpdateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReportUpdateRequest copyWith(void Function(ReportUpdateRequest) updates) =>
      super.copyWith((message) => updates(message as ReportUpdateRequest))
          as ReportUpdateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReportUpdateRequest create() => ReportUpdateRequest._();
  @$core.override
  ReportUpdateRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ReportUpdateRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ReportUpdateRequest>(create);
  static ReportUpdateRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get deviceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set deviceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDeviceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeviceId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get rolloutId => $_getSZ(1);
  @$pb.TagNumber(2)
  set rolloutId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRolloutId() => $_has(1);
  @$pb.TagNumber(2)
  void clearRolloutId() => $_clearField(2);

  @$pb.TagNumber(3)
  UpdateState get state => $_getN(2);
  @$pb.TagNumber(3)
  set state(UpdateState value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasState() => $_has(2);
  @$pb.TagNumber(3)
  void clearState() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get detail => $_getSZ(3);
  @$pb.TagNumber(4)
  set detail($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDetail() => $_has(3);
  @$pb.TagNumber(4)
  void clearDetail() => $_clearField(4);
}

class ReportUpdateResponse extends $pb.GeneratedMessage {
  factory ReportUpdateResponse({
    DeviceUpdate? update,
    FirmwareRollout? rollout,
  }) {
    final result = create();
    if (update != null) result.update = update;
    if (rollout != null) result.rollout = rollout;
    return result;
  }

  ReportUpdateResponse._();

  factory ReportUpdateResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ReportUpdateResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReportUpdateResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.device.v1'),
      createEmptyInstance: create)
    ..aOM<DeviceUpdate>(1, _omitFieldNames ? '' : 'update',
        subBuilder: DeviceUpdate.create)
    ..aOM<FirmwareRollout>(2, _omitFieldNames ? '' : 'rollout',
        subBuilder: FirmwareRollout.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReportUpdateResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReportUpdateResponse copyWith(void Function(ReportUpdateResponse) updates) =>
      super.copyWith((message) => updates(message as ReportUpdateResponse))
          as ReportUpdateResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReportUpdateResponse create() => ReportUpdateResponse._();
  @$core.override
  ReportUpdateResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ReportUpdateResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ReportUpdateResponse>(create);
  static ReportUpdateResponse? _defaultInstance;

  @$pb.TagNumber(1)
  DeviceUpdate get update => $_getN(0);
  @$pb.TagNumber(1)
  set update(DeviceUpdate value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasUpdate() => $_has(0);
  @$pb.TagNumber(1)
  void clearUpdate() => $_clearField(1);
  @$pb.TagNumber(1)
  DeviceUpdate ensureUpdate() => $_ensure(0);

  @$pb.TagNumber(2)
  FirmwareRollout get rollout => $_getN(1);
  @$pb.TagNumber(2)
  set rollout(FirmwareRollout value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasRollout() => $_has(1);
  @$pb.TagNumber(2)
  void clearRollout() => $_clearField(2);
  @$pb.TagNumber(2)
  FirmwareRollout ensureRollout() => $_ensure(1);
}

class ListRolloutsRequest extends $pb.GeneratedMessage {
  factory ListRolloutsRequest({
    $core.String? fleet,
    $core.int? pageSize,
    $core.String? pageToken,
  }) {
    final result = create();
    if (fleet != null) result.fleet = fleet;
    if (pageSize != null) result.pageSize = pageSize;
    if (pageToken != null) result.pageToken = pageToken;
    return result;
  }

  ListRolloutsRequest._();

  factory ListRolloutsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListRolloutsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListRolloutsRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.device.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fleet')
    ..aI(2, _omitFieldNames ? '' : 'pageSize')
    ..aOS(3, _omitFieldNames ? '' : 'pageToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListRolloutsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListRolloutsRequest copyWith(void Function(ListRolloutsRequest) updates) =>
      super.copyWith((message) => updates(message as ListRolloutsRequest))
          as ListRolloutsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListRolloutsRequest create() => ListRolloutsRequest._();
  @$core.override
  ListRolloutsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListRolloutsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListRolloutsRequest>(create);
  static ListRolloutsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fleet => $_getSZ(0);
  @$pb.TagNumber(1)
  set fleet($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFleet() => $_has(0);
  @$pb.TagNumber(1)
  void clearFleet() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get pageSize => $_getIZ(1);
  @$pb.TagNumber(2)
  set pageSize($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPageSize() => $_has(1);
  @$pb.TagNumber(2)
  void clearPageSize() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get pageToken => $_getSZ(2);
  @$pb.TagNumber(3)
  set pageToken($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPageToken() => $_has(2);
  @$pb.TagNumber(3)
  void clearPageToken() => $_clearField(3);
}

class ListRolloutsResponse extends $pb.GeneratedMessage {
  factory ListRolloutsResponse({
    $core.Iterable<FirmwareRollout>? rollouts,
    $core.String? nextPageToken,
    $core.int? totalCount,
  }) {
    final result = create();
    if (rollouts != null) result.rollouts.addAll(rollouts);
    if (nextPageToken != null) result.nextPageToken = nextPageToken;
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListRolloutsResponse._();

  factory ListRolloutsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListRolloutsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListRolloutsResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.device.v1'),
      createEmptyInstance: create)
    ..pPM<FirmwareRollout>(1, _omitFieldNames ? '' : 'rollouts',
        subBuilder: FirmwareRollout.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextPageToken')
    ..aI(3, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListRolloutsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListRolloutsResponse copyWith(void Function(ListRolloutsResponse) updates) =>
      super.copyWith((message) => updates(message as ListRolloutsResponse))
          as ListRolloutsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListRolloutsResponse create() => ListRolloutsResponse._();
  @$core.override
  ListRolloutsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListRolloutsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListRolloutsResponse>(create);
  static ListRolloutsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<FirmwareRollout> get rollouts => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get nextPageToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set nextPageToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNextPageToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextPageToken() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get totalCount => $_getIZ(2);
  @$pb.TagNumber(3)
  set totalCount($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTotalCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearTotalCount() => $_clearField(3);
}

/// DeviceService manages IoT hardware: provisioning, health and firmware.
class DeviceServiceApi {
  final $pb.RpcClient _client;

  DeviceServiceApi(this._client);

  $async.Future<ProvisionDeviceResponse> provisionDevice(
          $pb.ClientContext? ctx, ProvisionDeviceRequest request) =>
      _client.invoke<ProvisionDeviceResponse>(ctx, 'DeviceService',
          'ProvisionDevice', request, ProvisionDeviceResponse());
  $async.Future<GetDeviceResponse> getDevice(
          $pb.ClientContext? ctx, GetDeviceRequest request) =>
      _client.invoke<GetDeviceResponse>(
          ctx, 'DeviceService', 'GetDevice', request, GetDeviceResponse());
  $async.Future<ListDevicesResponse> listDevices(
          $pb.ClientContext? ctx, ListDevicesRequest request) =>
      _client.invoke<ListDevicesResponse>(
          ctx, 'DeviceService', 'ListDevices', request, ListDevicesResponse());
  $async.Future<RecordHeartbeatsResponse> recordHeartbeats(
          $pb.ClientContext? ctx, RecordHeartbeatsRequest request) =>
      _client.invoke<RecordHeartbeatsResponse>(ctx, 'DeviceService',
          'RecordHeartbeats', request, RecordHeartbeatsResponse());
  $async.Future<RetireDeviceResponse> retireDevice(
          $pb.ClientContext? ctx, RetireDeviceRequest request) =>
      _client.invoke<RetireDeviceResponse>(ctx, 'DeviceService', 'RetireDevice',
          request, RetireDeviceResponse());
  $async.Future<GetFleetHealthResponse> getFleetHealth(
          $pb.ClientContext? ctx, GetFleetHealthRequest request) =>
      _client.invoke<GetFleetHealthResponse>(ctx, 'DeviceService',
          'GetFleetHealth', request, GetFleetHealthResponse());
  $async.Future<CreateRolloutResponse> createRollout(
          $pb.ClientContext? ctx, CreateRolloutRequest request) =>
      _client.invoke<CreateRolloutResponse>(ctx, 'DeviceService',
          'CreateRollout', request, CreateRolloutResponse());
  $async.Future<AdvanceRolloutResponse> advanceRollout(
          $pb.ClientContext? ctx, AdvanceRolloutRequest request) =>
      _client.invoke<AdvanceRolloutResponse>(ctx, 'DeviceService',
          'AdvanceRollout', request, AdvanceRolloutResponse());
  $async.Future<ReportUpdateResponse> reportUpdate(
          $pb.ClientContext? ctx, ReportUpdateRequest request) =>
      _client.invoke<ReportUpdateResponse>(ctx, 'DeviceService', 'ReportUpdate',
          request, ReportUpdateResponse());
  $async.Future<ListRolloutsResponse> listRollouts(
          $pb.ClientContext? ctx, ListRolloutsRequest request) =>
      _client.invoke<ListRolloutsResponse>(ctx, 'DeviceService', 'ListRollouts',
          request, ListRolloutsResponse());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
