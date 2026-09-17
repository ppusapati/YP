// This is a generated file - do not edit.
//
// Generated from device.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// DeviceStatus is what the fleet view shows for one device.
class DeviceStatus extends $pb.ProtobufEnum {
  static const DeviceStatus DEVICE_STATUS_UNSPECIFIED =
      DeviceStatus._(0, _omitEnumNames ? '' : 'DEVICE_STATUS_UNSPECIFIED');

  /// Provisioned but never heard from. Distinct from OFFLINE, which means it
  /// worked and stopped: one is an installation that was never finished, the
  /// other is a device that needs a visit.
  static const DeviceStatus DEVICE_STATUS_PROVISIONED =
      DeviceStatus._(1, _omitEnumNames ? '' : 'DEVICE_STATUS_PROVISIONED');
  static const DeviceStatus DEVICE_STATUS_ONLINE =
      DeviceStatus._(2, _omitEnumNames ? '' : 'DEVICE_STATUS_ONLINE');
  static const DeviceStatus DEVICE_STATUS_OFFLINE =
      DeviceStatus._(3, _omitEnumNames ? '' : 'DEVICE_STATUS_OFFLINE');

  /// Reporting, but with a fault the device itself declared.
  static const DeviceStatus DEVICE_STATUS_DEGRADED =
      DeviceStatus._(4, _omitEnumNames ? '' : 'DEVICE_STATUS_DEGRADED');
  static const DeviceStatus DEVICE_STATUS_RETIRED =
      DeviceStatus._(5, _omitEnumNames ? '' : 'DEVICE_STATUS_RETIRED');

  static const $core.List<DeviceStatus> values = <DeviceStatus>[
    DEVICE_STATUS_UNSPECIFIED,
    DEVICE_STATUS_PROVISIONED,
    DEVICE_STATUS_ONLINE,
    DEVICE_STATUS_OFFLINE,
    DEVICE_STATUS_DEGRADED,
    DEVICE_STATUS_RETIRED,
  ];

  static final $core.List<DeviceStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static DeviceStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const DeviceStatus._(super.value, super.name);
}

/// DeviceKind is what the hardware does.
class DeviceKind extends $pb.ProtobufEnum {
  static const DeviceKind DEVICE_KIND_UNSPECIFIED =
      DeviceKind._(0, _omitEnumNames ? '' : 'DEVICE_KIND_UNSPECIFIED');
  static const DeviceKind DEVICE_KIND_SOIL_PROBE =
      DeviceKind._(1, _omitEnumNames ? '' : 'DEVICE_KIND_SOIL_PROBE');
  static const DeviceKind DEVICE_KIND_WEATHER_STATION =
      DeviceKind._(2, _omitEnumNames ? '' : 'DEVICE_KIND_WEATHER_STATION');
  static const DeviceKind DEVICE_KIND_IRRIGATION_VALVE =
      DeviceKind._(3, _omitEnumNames ? '' : 'DEVICE_KIND_IRRIGATION_VALVE');
  static const DeviceKind DEVICE_KIND_FLOW_METER =
      DeviceKind._(4, _omitEnumNames ? '' : 'DEVICE_KIND_FLOW_METER');
  static const DeviceKind DEVICE_KIND_GATEWAY =
      DeviceKind._(5, _omitEnumNames ? '' : 'DEVICE_KIND_GATEWAY');
  static const DeviceKind DEVICE_KIND_TRACTOR_TELEMATICS =
      DeviceKind._(6, _omitEnumNames ? '' : 'DEVICE_KIND_TRACTOR_TELEMATICS');

  static const $core.List<DeviceKind> values = <DeviceKind>[
    DEVICE_KIND_UNSPECIFIED,
    DEVICE_KIND_SOIL_PROBE,
    DEVICE_KIND_WEATHER_STATION,
    DEVICE_KIND_IRRIGATION_VALVE,
    DEVICE_KIND_FLOW_METER,
    DEVICE_KIND_GATEWAY,
    DEVICE_KIND_TRACTOR_TELEMATICS,
  ];

  static final $core.List<DeviceKind?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 6);
  static DeviceKind? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const DeviceKind._(super.value, super.name);
}

/// RolloutState is where a firmware rollout has got to.
class RolloutState extends $pb.ProtobufEnum {
  static const RolloutState ROLLOUT_STATE_UNSPECIFIED =
      RolloutState._(0, _omitEnumNames ? '' : 'ROLLOUT_STATE_UNSPECIFIED');
  static const RolloutState ROLLOUT_STATE_PENDING =
      RolloutState._(1, _omitEnumNames ? '' : 'ROLLOUT_STATE_PENDING');
  static const RolloutState ROLLOUT_STATE_IN_PROGRESS =
      RolloutState._(2, _omitEnumNames ? '' : 'ROLLOUT_STATE_IN_PROGRESS');
  static const RolloutState ROLLOUT_STATE_PAUSED =
      RolloutState._(3, _omitEnumNames ? '' : 'ROLLOUT_STATE_PAUSED');
  static const RolloutState ROLLOUT_STATE_COMPLETED =
      RolloutState._(4, _omitEnumNames ? '' : 'ROLLOUT_STATE_COMPLETED');

  /// Stopped because too many devices failed to take the update.
  static const RolloutState ROLLOUT_STATE_HALTED =
      RolloutState._(5, _omitEnumNames ? '' : 'ROLLOUT_STATE_HALTED');

  static const $core.List<RolloutState> values = <RolloutState>[
    ROLLOUT_STATE_UNSPECIFIED,
    ROLLOUT_STATE_PENDING,
    ROLLOUT_STATE_IN_PROGRESS,
    ROLLOUT_STATE_PAUSED,
    ROLLOUT_STATE_COMPLETED,
    ROLLOUT_STATE_HALTED,
  ];

  static final $core.List<RolloutState?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static RolloutState? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const RolloutState._(super.value, super.name);
}

/// UpdateState is one device's progress through a rollout.
class UpdateState extends $pb.ProtobufEnum {
  static const UpdateState UPDATE_STATE_UNSPECIFIED =
      UpdateState._(0, _omitEnumNames ? '' : 'UPDATE_STATE_UNSPECIFIED');
  static const UpdateState UPDATE_STATE_OFFERED =
      UpdateState._(1, _omitEnumNames ? '' : 'UPDATE_STATE_OFFERED');
  static const UpdateState UPDATE_STATE_DOWNLOADING =
      UpdateState._(2, _omitEnumNames ? '' : 'UPDATE_STATE_DOWNLOADING');
  static const UpdateState UPDATE_STATE_INSTALLING =
      UpdateState._(3, _omitEnumNames ? '' : 'UPDATE_STATE_INSTALLING');
  static const UpdateState UPDATE_STATE_SUCCEEDED =
      UpdateState._(4, _omitEnumNames ? '' : 'UPDATE_STATE_SUCCEEDED');
  static const UpdateState UPDATE_STATE_FAILED =
      UpdateState._(5, _omitEnumNames ? '' : 'UPDATE_STATE_FAILED');

  /// The device came back on its previous firmware after a failed install.
  static const UpdateState UPDATE_STATE_ROLLED_BACK =
      UpdateState._(6, _omitEnumNames ? '' : 'UPDATE_STATE_ROLLED_BACK');

  static const $core.List<UpdateState> values = <UpdateState>[
    UPDATE_STATE_UNSPECIFIED,
    UPDATE_STATE_OFFERED,
    UPDATE_STATE_DOWNLOADING,
    UPDATE_STATE_INSTALLING,
    UPDATE_STATE_SUCCEEDED,
    UPDATE_STATE_FAILED,
    UPDATE_STATE_ROLLED_BACK,
  ];

  static final $core.List<UpdateState?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 6);
  static UpdateState? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const UpdateState._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
