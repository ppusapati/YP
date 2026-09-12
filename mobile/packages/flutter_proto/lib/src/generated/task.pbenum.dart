// This is a generated file - do not edit.
//
// Generated from task.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class TaskStatus extends $pb.ProtobufEnum {
  static const TaskStatus TASK_STATUS_UNSPECIFIED =
      TaskStatus._(0, _omitEnumNames ? '' : 'TASK_STATUS_UNSPECIFIED');
  static const TaskStatus TASK_STATUS_PENDING =
      TaskStatus._(1, _omitEnumNames ? '' : 'TASK_STATUS_PENDING');
  static const TaskStatus TASK_STATUS_IN_PROGRESS =
      TaskStatus._(2, _omitEnumNames ? '' : 'TASK_STATUS_IN_PROGRESS');
  static const TaskStatus TASK_STATUS_COMPLETED =
      TaskStatus._(3, _omitEnumNames ? '' : 'TASK_STATUS_COMPLETED');
  static const TaskStatus TASK_STATUS_CANCELLED =
      TaskStatus._(4, _omitEnumNames ? '' : 'TASK_STATUS_CANCELLED');

  static const $core.List<TaskStatus> values = <TaskStatus>[
    TASK_STATUS_UNSPECIFIED,
    TASK_STATUS_PENDING,
    TASK_STATUS_IN_PROGRESS,
    TASK_STATUS_COMPLETED,
    TASK_STATUS_CANCELLED,
  ];

  static final $core.List<TaskStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static TaskStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const TaskStatus._(super.value, super.name);
}

class TaskPriority extends $pb.ProtobufEnum {
  static const TaskPriority TASK_PRIORITY_UNSPECIFIED =
      TaskPriority._(0, _omitEnumNames ? '' : 'TASK_PRIORITY_UNSPECIFIED');
  static const TaskPriority TASK_PRIORITY_LOW =
      TaskPriority._(1, _omitEnumNames ? '' : 'TASK_PRIORITY_LOW');
  static const TaskPriority TASK_PRIORITY_MEDIUM =
      TaskPriority._(2, _omitEnumNames ? '' : 'TASK_PRIORITY_MEDIUM');
  static const TaskPriority TASK_PRIORITY_HIGH =
      TaskPriority._(3, _omitEnumNames ? '' : 'TASK_PRIORITY_HIGH');
  static const TaskPriority TASK_PRIORITY_URGENT =
      TaskPriority._(4, _omitEnumNames ? '' : 'TASK_PRIORITY_URGENT');

  static const $core.List<TaskPriority> values = <TaskPriority>[
    TASK_PRIORITY_UNSPECIFIED,
    TASK_PRIORITY_LOW,
    TASK_PRIORITY_MEDIUM,
    TASK_PRIORITY_HIGH,
    TASK_PRIORITY_URGENT,
  ];

  static final $core.List<TaskPriority?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static TaskPriority? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const TaskPriority._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
