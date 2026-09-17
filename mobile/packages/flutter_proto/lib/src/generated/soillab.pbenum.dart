// This is a generated file - do not edit.
//
// Generated from soillab.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// ReportFormat is how a lab delivered its results.
class ReportFormat extends $pb.ProtobufEnum {
  static const ReportFormat REPORT_FORMAT_UNSPECIFIED =
      ReportFormat._(0, _omitEnumNames ? '' : 'REPORT_FORMAT_UNSPECIFIED');
  static const ReportFormat REPORT_FORMAT_CSV =
      ReportFormat._(1, _omitEnumNames ? '' : 'REPORT_FORMAT_CSV');

  /// A PDF is accepted and stored but not parsed. Extracting numbers from a
  /// lab's PDF layout is OCR guesswork, and a mis-read potassium figure drives
  /// a fertiliser prescription — so the file is kept for a human to read and
  /// the values are entered rather than inferred.
  static const ReportFormat REPORT_FORMAT_PDF =
      ReportFormat._(2, _omitEnumNames ? '' : 'REPORT_FORMAT_PDF');

  static const $core.List<ReportFormat> values = <ReportFormat>[
    REPORT_FORMAT_UNSPECIFIED,
    REPORT_FORMAT_CSV,
    REPORT_FORMAT_PDF,
  ];

  static final $core.List<ReportFormat?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static ReportFormat? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ReportFormat._(super.value, super.name);
}

/// ImportStatus is where one report has got to.
class ImportStatus extends $pb.ProtobufEnum {
  static const ImportStatus IMPORT_STATUS_UNSPECIFIED =
      ImportStatus._(0, _omitEnumNames ? '' : 'IMPORT_STATUS_UNSPECIFIED');
  static const ImportStatus IMPORT_STATUS_RECEIVED =
      ImportStatus._(1, _omitEnumNames ? '' : 'IMPORT_STATUS_RECEIVED');
  static const ImportStatus IMPORT_STATUS_PARSED =
      ImportStatus._(2, _omitEnumNames ? '' : 'IMPORT_STATUS_PARSED');

  /// Parsed, but at least one row could not be matched or trusted. The report
  /// is held for review rather than pushed into soil-service.
  static const ImportStatus IMPORT_STATUS_NEEDS_REVIEW =
      ImportStatus._(3, _omitEnumNames ? '' : 'IMPORT_STATUS_NEEDS_REVIEW');
  static const ImportStatus IMPORT_STATUS_APPLIED =
      ImportStatus._(4, _omitEnumNames ? '' : 'IMPORT_STATUS_APPLIED');
  static const ImportStatus IMPORT_STATUS_REJECTED =
      ImportStatus._(5, _omitEnumNames ? '' : 'IMPORT_STATUS_REJECTED');

  static const $core.List<ImportStatus> values = <ImportStatus>[
    IMPORT_STATUS_UNSPECIFIED,
    IMPORT_STATUS_RECEIVED,
    IMPORT_STATUS_PARSED,
    IMPORT_STATUS_NEEDS_REVIEW,
    IMPORT_STATUS_APPLIED,
    IMPORT_STATUS_REJECTED,
  ];

  static final $core.List<ImportStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static ImportStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ImportStatus._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
