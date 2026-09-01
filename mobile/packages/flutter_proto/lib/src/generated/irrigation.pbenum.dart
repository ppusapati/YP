// This is a generated file - do not edit.
//
// Generated from irrigation.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class ScheduleType extends $pb.ProtobufEnum {
  static const ScheduleType SCHEDULE_TYPE_UNSPECIFIED =
      ScheduleType._(0, _omitEnumNames ? '' : 'SCHEDULE_TYPE_UNSPECIFIED');
  static const ScheduleType SCHEDULE_TYPE_FIXED =
      ScheduleType._(1, _omitEnumNames ? '' : 'SCHEDULE_TYPE_FIXED');
  static const ScheduleType SCHEDULE_TYPE_ADAPTIVE =
      ScheduleType._(2, _omitEnumNames ? '' : 'SCHEDULE_TYPE_ADAPTIVE');
  static const ScheduleType SCHEDULE_TYPE_AI_DRIVEN =
      ScheduleType._(3, _omitEnumNames ? '' : 'SCHEDULE_TYPE_AI_DRIVEN');

  static const $core.List<ScheduleType> values = <ScheduleType>[
    SCHEDULE_TYPE_UNSPECIFIED,
    SCHEDULE_TYPE_FIXED,
    SCHEDULE_TYPE_ADAPTIVE,
    SCHEDULE_TYPE_AI_DRIVEN,
  ];

  static final $core.List<ScheduleType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static ScheduleType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ScheduleType._(super.value, super.name);
}

class Frequency extends $pb.ProtobufEnum {
  static const Frequency FREQUENCY_UNSPECIFIED =
      Frequency._(0, _omitEnumNames ? '' : 'FREQUENCY_UNSPECIFIED');
  static const Frequency FREQUENCY_DAILY =
      Frequency._(1, _omitEnumNames ? '' : 'FREQUENCY_DAILY');
  static const Frequency FREQUENCY_EVERY_OTHER_DAY =
      Frequency._(2, _omitEnumNames ? '' : 'FREQUENCY_EVERY_OTHER_DAY');
  static const Frequency FREQUENCY_WEEKLY =
      Frequency._(3, _omitEnumNames ? '' : 'FREQUENCY_WEEKLY');
  static const Frequency FREQUENCY_CUSTOM =
      Frequency._(4, _omitEnumNames ? '' : 'FREQUENCY_CUSTOM');

  static const $core.List<Frequency> values = <Frequency>[
    FREQUENCY_UNSPECIFIED,
    FREQUENCY_DAILY,
    FREQUENCY_EVERY_OTHER_DAY,
    FREQUENCY_WEEKLY,
    FREQUENCY_CUSTOM,
  ];

  static final $core.List<Frequency?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static Frequency? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Frequency._(super.value, super.name);
}

class ControllerType extends $pb.ProtobufEnum {
  static const ControllerType CONTROLLER_TYPE_UNSPECIFIED =
      ControllerType._(0, _omitEnumNames ? '' : 'CONTROLLER_TYPE_UNSPECIFIED');
  static const ControllerType CONTROLLER_TYPE_DRIP =
      ControllerType._(1, _omitEnumNames ? '' : 'CONTROLLER_TYPE_DRIP');
  static const ControllerType CONTROLLER_TYPE_VALVE =
      ControllerType._(2, _omitEnumNames ? '' : 'CONTROLLER_TYPE_VALVE');
  static const ControllerType CONTROLLER_TYPE_PUMP =
      ControllerType._(3, _omitEnumNames ? '' : 'CONTROLLER_TYPE_PUMP');
  static const ControllerType CONTROLLER_TYPE_SPRINKLER =
      ControllerType._(4, _omitEnumNames ? '' : 'CONTROLLER_TYPE_SPRINKLER');

  static const $core.List<ControllerType> values = <ControllerType>[
    CONTROLLER_TYPE_UNSPECIFIED,
    CONTROLLER_TYPE_DRIP,
    CONTROLLER_TYPE_VALVE,
    CONTROLLER_TYPE_PUMP,
    CONTROLLER_TYPE_SPRINKLER,
  ];

  static final $core.List<ControllerType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static ControllerType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ControllerType._(super.value, super.name);
}

class Protocol extends $pb.ProtobufEnum {
  static const Protocol PROTOCOL_UNSPECIFIED =
      Protocol._(0, _omitEnumNames ? '' : 'PROTOCOL_UNSPECIFIED');
  static const Protocol PROTOCOL_MQTT =
      Protocol._(1, _omitEnumNames ? '' : 'PROTOCOL_MQTT');
  static const Protocol PROTOCOL_LORAWAN =
      Protocol._(2, _omitEnumNames ? '' : 'PROTOCOL_LORAWAN');
  static const Protocol PROTOCOL_MODBUS =
      Protocol._(3, _omitEnumNames ? '' : 'PROTOCOL_MODBUS');

  static const $core.List<Protocol> values = <Protocol>[
    PROTOCOL_UNSPECIFIED,
    PROTOCOL_MQTT,
    PROTOCOL_LORAWAN,
    PROTOCOL_MODBUS,
  ];

  static final $core.List<Protocol?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static Protocol? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Protocol._(super.value, super.name);
}

class ControllerStatus extends $pb.ProtobufEnum {
  static const ControllerStatus CONTROLLER_STATUS_UNSPECIFIED =
      ControllerStatus._(
          0, _omitEnumNames ? '' : 'CONTROLLER_STATUS_UNSPECIFIED');
  static const ControllerStatus CONTROLLER_STATUS_ONLINE =
      ControllerStatus._(1, _omitEnumNames ? '' : 'CONTROLLER_STATUS_ONLINE');
  static const ControllerStatus CONTROLLER_STATUS_OFFLINE =
      ControllerStatus._(2, _omitEnumNames ? '' : 'CONTROLLER_STATUS_OFFLINE');
  static const ControllerStatus CONTROLLER_STATUS_ERROR =
      ControllerStatus._(3, _omitEnumNames ? '' : 'CONTROLLER_STATUS_ERROR');

  static const $core.List<ControllerStatus> values = <ControllerStatus>[
    CONTROLLER_STATUS_UNSPECIFIED,
    CONTROLLER_STATUS_ONLINE,
    CONTROLLER_STATUS_OFFLINE,
    CONTROLLER_STATUS_ERROR,
  ];

  static final $core.List<ControllerStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static ControllerStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ControllerStatus._(super.value, super.name);
}

class IrrigationStatus extends $pb.ProtobufEnum {
  static const IrrigationStatus IRRIGATION_STATUS_UNSPECIFIED =
      IrrigationStatus._(
          0, _omitEnumNames ? '' : 'IRRIGATION_STATUS_UNSPECIFIED');
  static const IrrigationStatus IRRIGATION_STATUS_SCHEDULED =
      IrrigationStatus._(
          1, _omitEnumNames ? '' : 'IRRIGATION_STATUS_SCHEDULED');
  static const IrrigationStatus IRRIGATION_STATUS_ACTIVE =
      IrrigationStatus._(2, _omitEnumNames ? '' : 'IRRIGATION_STATUS_ACTIVE');
  static const IrrigationStatus IRRIGATION_STATUS_COMPLETED =
      IrrigationStatus._(
          3, _omitEnumNames ? '' : 'IRRIGATION_STATUS_COMPLETED');
  static const IrrigationStatus IRRIGATION_STATUS_CANCELLED =
      IrrigationStatus._(
          4, _omitEnumNames ? '' : 'IRRIGATION_STATUS_CANCELLED');
  static const IrrigationStatus IRRIGATION_STATUS_FAILED =
      IrrigationStatus._(5, _omitEnumNames ? '' : 'IRRIGATION_STATUS_FAILED');

  static const $core.List<IrrigationStatus> values = <IrrigationStatus>[
    IRRIGATION_STATUS_UNSPECIFIED,
    IRRIGATION_STATUS_SCHEDULED,
    IRRIGATION_STATUS_ACTIVE,
    IRRIGATION_STATUS_COMPLETED,
    IRRIGATION_STATUS_CANCELLED,
    IRRIGATION_STATUS_FAILED,
  ];

  static final $core.List<IrrigationStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static IrrigationStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const IrrigationStatus._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
