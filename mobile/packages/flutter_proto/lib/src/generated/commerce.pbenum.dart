// This is a generated file - do not edit.
//
// Generated from commerce.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// ListingStatus tracks the lifecycle of a marketplace listing.
class ListingStatus extends $pb.ProtobufEnum {
  static const ListingStatus LISTING_STATUS_UNSPECIFIED =
      ListingStatus._(0, _omitEnumNames ? '' : 'LISTING_STATUS_UNSPECIFIED');
  static const ListingStatus LISTING_STATUS_DRAFT =
      ListingStatus._(1, _omitEnumNames ? '' : 'LISTING_STATUS_DRAFT');
  static const ListingStatus LISTING_STATUS_ACTIVE =
      ListingStatus._(2, _omitEnumNames ? '' : 'LISTING_STATUS_ACTIVE');
  static const ListingStatus LISTING_STATUS_SOLD_OUT =
      ListingStatus._(3, _omitEnumNames ? '' : 'LISTING_STATUS_SOLD_OUT');
  static const ListingStatus LISTING_STATUS_EXPIRED =
      ListingStatus._(4, _omitEnumNames ? '' : 'LISTING_STATUS_EXPIRED');
  static const ListingStatus LISTING_STATUS_CANCELLED =
      ListingStatus._(5, _omitEnumNames ? '' : 'LISTING_STATUS_CANCELLED');

  static const $core.List<ListingStatus> values = <ListingStatus>[
    LISTING_STATUS_UNSPECIFIED,
    LISTING_STATUS_DRAFT,
    LISTING_STATUS_ACTIVE,
    LISTING_STATUS_SOLD_OUT,
    LISTING_STATUS_EXPIRED,
    LISTING_STATUS_CANCELLED,
  ];

  static final $core.List<ListingStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static ListingStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ListingStatus._(super.value, super.name);
}

/// OrderStatus tracks the lifecycle of an order.
class OrderStatus extends $pb.ProtobufEnum {
  static const OrderStatus ORDER_STATUS_UNSPECIFIED =
      OrderStatus._(0, _omitEnumNames ? '' : 'ORDER_STATUS_UNSPECIFIED');
  static const OrderStatus ORDER_STATUS_PENDING =
      OrderStatus._(1, _omitEnumNames ? '' : 'ORDER_STATUS_PENDING');
  static const OrderStatus ORDER_STATUS_CONFIRMED =
      OrderStatus._(2, _omitEnumNames ? '' : 'ORDER_STATUS_CONFIRMED');
  static const OrderStatus ORDER_STATUS_PROCESSING =
      OrderStatus._(3, _omitEnumNames ? '' : 'ORDER_STATUS_PROCESSING');
  static const OrderStatus ORDER_STATUS_SHIPPED =
      OrderStatus._(4, _omitEnumNames ? '' : 'ORDER_STATUS_SHIPPED');
  static const OrderStatus ORDER_STATUS_DELIVERED =
      OrderStatus._(5, _omitEnumNames ? '' : 'ORDER_STATUS_DELIVERED');
  static const OrderStatus ORDER_STATUS_COMPLETED =
      OrderStatus._(6, _omitEnumNames ? '' : 'ORDER_STATUS_COMPLETED');
  static const OrderStatus ORDER_STATUS_CANCELLED =
      OrderStatus._(7, _omitEnumNames ? '' : 'ORDER_STATUS_CANCELLED');
  static const OrderStatus ORDER_STATUS_DISPUTED =
      OrderStatus._(8, _omitEnumNames ? '' : 'ORDER_STATUS_DISPUTED');

  static const $core.List<OrderStatus> values = <OrderStatus>[
    ORDER_STATUS_UNSPECIFIED,
    ORDER_STATUS_PENDING,
    ORDER_STATUS_CONFIRMED,
    ORDER_STATUS_PROCESSING,
    ORDER_STATUS_SHIPPED,
    ORDER_STATUS_DELIVERED,
    ORDER_STATUS_COMPLETED,
    ORDER_STATUS_CANCELLED,
    ORDER_STATUS_DISPUTED,
  ];

  static final $core.List<OrderStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 8);
  static OrderStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const OrderStatus._(super.value, super.name);
}

/// PaymentStatus tracks payment state.
class PaymentStatus extends $pb.ProtobufEnum {
  static const PaymentStatus PAYMENT_STATUS_UNSPECIFIED =
      PaymentStatus._(0, _omitEnumNames ? '' : 'PAYMENT_STATUS_UNSPECIFIED');
  static const PaymentStatus PAYMENT_STATUS_PENDING =
      PaymentStatus._(1, _omitEnumNames ? '' : 'PAYMENT_STATUS_PENDING');
  static const PaymentStatus PAYMENT_STATUS_PAID =
      PaymentStatus._(2, _omitEnumNames ? '' : 'PAYMENT_STATUS_PAID');
  static const PaymentStatus PAYMENT_STATUS_REFUNDED =
      PaymentStatus._(3, _omitEnumNames ? '' : 'PAYMENT_STATUS_REFUNDED');

  static const $core.List<PaymentStatus> values = <PaymentStatus>[
    PAYMENT_STATUS_UNSPECIFIED,
    PAYMENT_STATUS_PENDING,
    PAYMENT_STATUS_PAID,
    PAYMENT_STATUS_REFUNDED,
  ];

  static final $core.List<PaymentStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static PaymentStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const PaymentStatus._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
