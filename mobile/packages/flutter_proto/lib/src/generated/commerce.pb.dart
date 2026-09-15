// This is a generated file - do not edit.
//
// Generated from commerce.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart'
    as $0;

import 'commerce.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'commerce.pbenum.dart';

/// MarketplaceListing is a produce listing posted by a farmer.
class MarketplaceListing extends $pb.GeneratedMessage {
  factory MarketplaceListing({
    $core.String? id,
    $core.String? tenantId,
    $core.String? farmId,
    $core.String? cropId,
    $core.String? productName,
    $core.String? productType,
    $core.String? description,
    $core.double? quantityAvailable,
    $core.String? quantityUnit,
    $fixnum.Int64? pricePerUnitPaise,
    $core.String? currency,
    $core.double? minOrderQuantity,
    $core.String? qualityGrade,
    $core.String? traceabilityRecordId,
    ListingStatus? status,
    $core.String? location,
    $core.String? region,
    $core.Iterable<$core.String>? imageUrls,
    $0.Timestamp? availableFrom,
    $0.Timestamp? availableTo,
    $core.String? createdBy,
    $fixnum.Int64? version,
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
    $core.String? batchId,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    if (farmId != null) result.farmId = farmId;
    if (cropId != null) result.cropId = cropId;
    if (productName != null) result.productName = productName;
    if (productType != null) result.productType = productType;
    if (description != null) result.description = description;
    if (quantityAvailable != null) result.quantityAvailable = quantityAvailable;
    if (quantityUnit != null) result.quantityUnit = quantityUnit;
    if (pricePerUnitPaise != null) result.pricePerUnitPaise = pricePerUnitPaise;
    if (currency != null) result.currency = currency;
    if (minOrderQuantity != null) result.minOrderQuantity = minOrderQuantity;
    if (qualityGrade != null) result.qualityGrade = qualityGrade;
    if (traceabilityRecordId != null)
      result.traceabilityRecordId = traceabilityRecordId;
    if (status != null) result.status = status;
    if (location != null) result.location = location;
    if (region != null) result.region = region;
    if (imageUrls != null) result.imageUrls.addAll(imageUrls);
    if (availableFrom != null) result.availableFrom = availableFrom;
    if (availableTo != null) result.availableTo = availableTo;
    if (createdBy != null) result.createdBy = createdBy;
    if (version != null) result.version = version;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (batchId != null) result.batchId = batchId;
    return result;
  }

  MarketplaceListing._();

  factory MarketplaceListing.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MarketplaceListing.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MarketplaceListing',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.commerce.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'farmId')
    ..aOS(4, _omitFieldNames ? '' : 'cropId')
    ..aOS(5, _omitFieldNames ? '' : 'productName')
    ..aOS(6, _omitFieldNames ? '' : 'productType')
    ..aOS(7, _omitFieldNames ? '' : 'description')
    ..aD(8, _omitFieldNames ? '' : 'quantityAvailable')
    ..aOS(9, _omitFieldNames ? '' : 'quantityUnit')
    ..aInt64(10, _omitFieldNames ? '' : 'pricePerUnitPaise')
    ..aOS(11, _omitFieldNames ? '' : 'currency')
    ..aD(12, _omitFieldNames ? '' : 'minOrderQuantity')
    ..aOS(13, _omitFieldNames ? '' : 'qualityGrade')
    ..aOS(14, _omitFieldNames ? '' : 'traceabilityRecordId')
    ..aE<ListingStatus>(15, _omitFieldNames ? '' : 'status',
        enumValues: ListingStatus.values)
    ..aOS(16, _omitFieldNames ? '' : 'location')
    ..aOS(17, _omitFieldNames ? '' : 'region')
    ..pPS(18, _omitFieldNames ? '' : 'imageUrls')
    ..aOM<$0.Timestamp>(19, _omitFieldNames ? '' : 'availableFrom',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(20, _omitFieldNames ? '' : 'availableTo',
        subBuilder: $0.Timestamp.create)
    ..aOS(21, _omitFieldNames ? '' : 'createdBy')
    ..aInt64(22, _omitFieldNames ? '' : 'version')
    ..aOM<$0.Timestamp>(23, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(24, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $0.Timestamp.create)
    ..aOS(25, _omitFieldNames ? '' : 'batchId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarketplaceListing clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarketplaceListing copyWith(void Function(MarketplaceListing) updates) =>
      super.copyWith((message) => updates(message as MarketplaceListing))
          as MarketplaceListing;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MarketplaceListing create() => MarketplaceListing._();
  @$core.override
  MarketplaceListing createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MarketplaceListing getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MarketplaceListing>(create);
  static MarketplaceListing? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get tenantId => $_getSZ(1);
  @$pb.TagNumber(2)
  set tenantId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTenantId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTenantId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get farmId => $_getSZ(2);
  @$pb.TagNumber(3)
  set farmId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFarmId() => $_has(2);
  @$pb.TagNumber(3)
  void clearFarmId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get cropId => $_getSZ(3);
  @$pb.TagNumber(4)
  set cropId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCropId() => $_has(3);
  @$pb.TagNumber(4)
  void clearCropId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get productName => $_getSZ(4);
  @$pb.TagNumber(5)
  set productName($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasProductName() => $_has(4);
  @$pb.TagNumber(5)
  void clearProductName() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get productType => $_getSZ(5);
  @$pb.TagNumber(6)
  set productType($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasProductType() => $_has(5);
  @$pb.TagNumber(6)
  void clearProductType() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get description => $_getSZ(6);
  @$pb.TagNumber(7)
  set description($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasDescription() => $_has(6);
  @$pb.TagNumber(7)
  void clearDescription() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get quantityAvailable => $_getN(7);
  @$pb.TagNumber(8)
  set quantityAvailable($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasQuantityAvailable() => $_has(7);
  @$pb.TagNumber(8)
  void clearQuantityAvailable() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get quantityUnit => $_getSZ(8);
  @$pb.TagNumber(9)
  set quantityUnit($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasQuantityUnit() => $_has(8);
  @$pb.TagNumber(9)
  void clearQuantityUnit() => $_clearField(9);

  @$pb.TagNumber(10)
  $fixnum.Int64 get pricePerUnitPaise => $_getI64(9);
  @$pb.TagNumber(10)
  set pricePerUnitPaise($fixnum.Int64 value) => $_setInt64(9, value);
  @$pb.TagNumber(10)
  $core.bool hasPricePerUnitPaise() => $_has(9);
  @$pb.TagNumber(10)
  void clearPricePerUnitPaise() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get currency => $_getSZ(10);
  @$pb.TagNumber(11)
  set currency($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasCurrency() => $_has(10);
  @$pb.TagNumber(11)
  void clearCurrency() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.double get minOrderQuantity => $_getN(11);
  @$pb.TagNumber(12)
  set minOrderQuantity($core.double value) => $_setDouble(11, value);
  @$pb.TagNumber(12)
  $core.bool hasMinOrderQuantity() => $_has(11);
  @$pb.TagNumber(12)
  void clearMinOrderQuantity() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get qualityGrade => $_getSZ(12);
  @$pb.TagNumber(13)
  set qualityGrade($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasQualityGrade() => $_has(12);
  @$pb.TagNumber(13)
  void clearQualityGrade() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.String get traceabilityRecordId => $_getSZ(13);
  @$pb.TagNumber(14)
  set traceabilityRecordId($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasTraceabilityRecordId() => $_has(13);
  @$pb.TagNumber(14)
  void clearTraceabilityRecordId() => $_clearField(14);

  @$pb.TagNumber(15)
  ListingStatus get status => $_getN(14);
  @$pb.TagNumber(15)
  set status(ListingStatus value) => $_setField(15, value);
  @$pb.TagNumber(15)
  $core.bool hasStatus() => $_has(14);
  @$pb.TagNumber(15)
  void clearStatus() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.String get location => $_getSZ(15);
  @$pb.TagNumber(16)
  set location($core.String value) => $_setString(15, value);
  @$pb.TagNumber(16)
  $core.bool hasLocation() => $_has(15);
  @$pb.TagNumber(16)
  void clearLocation() => $_clearField(16);

  @$pb.TagNumber(17)
  $core.String get region => $_getSZ(16);
  @$pb.TagNumber(17)
  set region($core.String value) => $_setString(16, value);
  @$pb.TagNumber(17)
  $core.bool hasRegion() => $_has(16);
  @$pb.TagNumber(17)
  void clearRegion() => $_clearField(17);

  @$pb.TagNumber(18)
  $pb.PbList<$core.String> get imageUrls => $_getList(17);

  @$pb.TagNumber(19)
  $0.Timestamp get availableFrom => $_getN(18);
  @$pb.TagNumber(19)
  set availableFrom($0.Timestamp value) => $_setField(19, value);
  @$pb.TagNumber(19)
  $core.bool hasAvailableFrom() => $_has(18);
  @$pb.TagNumber(19)
  void clearAvailableFrom() => $_clearField(19);
  @$pb.TagNumber(19)
  $0.Timestamp ensureAvailableFrom() => $_ensure(18);

  @$pb.TagNumber(20)
  $0.Timestamp get availableTo => $_getN(19);
  @$pb.TagNumber(20)
  set availableTo($0.Timestamp value) => $_setField(20, value);
  @$pb.TagNumber(20)
  $core.bool hasAvailableTo() => $_has(19);
  @$pb.TagNumber(20)
  void clearAvailableTo() => $_clearField(20);
  @$pb.TagNumber(20)
  $0.Timestamp ensureAvailableTo() => $_ensure(19);

  @$pb.TagNumber(21)
  $core.String get createdBy => $_getSZ(20);
  @$pb.TagNumber(21)
  set createdBy($core.String value) => $_setString(20, value);
  @$pb.TagNumber(21)
  $core.bool hasCreatedBy() => $_has(20);
  @$pb.TagNumber(21)
  void clearCreatedBy() => $_clearField(21);

  @$pb.TagNumber(22)
  $fixnum.Int64 get version => $_getI64(21);
  @$pb.TagNumber(22)
  set version($fixnum.Int64 value) => $_setInt64(21, value);
  @$pb.TagNumber(22)
  $core.bool hasVersion() => $_has(21);
  @$pb.TagNumber(22)
  void clearVersion() => $_clearField(22);

  @$pb.TagNumber(23)
  $0.Timestamp get createdAt => $_getN(22);
  @$pb.TagNumber(23)
  set createdAt($0.Timestamp value) => $_setField(23, value);
  @$pb.TagNumber(23)
  $core.bool hasCreatedAt() => $_has(22);
  @$pb.TagNumber(23)
  void clearCreatedAt() => $_clearField(23);
  @$pb.TagNumber(23)
  $0.Timestamp ensureCreatedAt() => $_ensure(22);

  @$pb.TagNumber(24)
  $0.Timestamp get updatedAt => $_getN(23);
  @$pb.TagNumber(24)
  set updatedAt($0.Timestamp value) => $_setField(24, value);
  @$pb.TagNumber(24)
  $core.bool hasUpdatedAt() => $_has(23);
  @$pb.TagNumber(24)
  void clearUpdatedAt() => $_clearField(24);
  @$pb.TagNumber(24)
  $0.Timestamp ensureUpdatedAt() => $_ensure(23);

  @$pb.TagNumber(25)
  $core.String get batchId => $_getSZ(24);
  @$pb.TagNumber(25)
  set batchId($core.String value) => $_setString(24, value);
  @$pb.TagNumber(25)
  $core.bool hasBatchId() => $_has(24);
  @$pb.TagNumber(25)
  void clearBatchId() => $_clearField(25);
}

/// Order represents a purchase order.
class Order extends $pb.GeneratedMessage {
  factory Order({
    $core.String? id,
    $core.String? tenantId,
    $core.String? listingId,
    $core.String? buyerId,
    $core.String? sellerId,
    $core.double? quantity,
    $core.String? quantityUnit,
    $fixnum.Int64? unitPricePaise,
    $fixnum.Int64? totalAmountPaise,
    $core.String? currency,
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    $core.String? paymentReference,
    $core.String? deliveryMethod,
    $core.String? deliveryAddress,
    $core.String? deliveryNotes,
    $0.Timestamp? estimatedDeliveryDate,
    $0.Timestamp? actualDeliveryDate,
    $core.String? notes,
    $core.String? createdBy,
    $fixnum.Int64? version,
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    if (listingId != null) result.listingId = listingId;
    if (buyerId != null) result.buyerId = buyerId;
    if (sellerId != null) result.sellerId = sellerId;
    if (quantity != null) result.quantity = quantity;
    if (quantityUnit != null) result.quantityUnit = quantityUnit;
    if (unitPricePaise != null) result.unitPricePaise = unitPricePaise;
    if (totalAmountPaise != null) result.totalAmountPaise = totalAmountPaise;
    if (currency != null) result.currency = currency;
    if (status != null) result.status = status;
    if (paymentStatus != null) result.paymentStatus = paymentStatus;
    if (paymentReference != null) result.paymentReference = paymentReference;
    if (deliveryMethod != null) result.deliveryMethod = deliveryMethod;
    if (deliveryAddress != null) result.deliveryAddress = deliveryAddress;
    if (deliveryNotes != null) result.deliveryNotes = deliveryNotes;
    if (estimatedDeliveryDate != null)
      result.estimatedDeliveryDate = estimatedDeliveryDate;
    if (actualDeliveryDate != null)
      result.actualDeliveryDate = actualDeliveryDate;
    if (notes != null) result.notes = notes;
    if (createdBy != null) result.createdBy = createdBy;
    if (version != null) result.version = version;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  Order._();

  factory Order.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Order.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Order',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.commerce.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'listingId')
    ..aOS(4, _omitFieldNames ? '' : 'buyerId')
    ..aOS(5, _omitFieldNames ? '' : 'sellerId')
    ..aD(6, _omitFieldNames ? '' : 'quantity')
    ..aOS(7, _omitFieldNames ? '' : 'quantityUnit')
    ..aInt64(8, _omitFieldNames ? '' : 'unitPricePaise')
    ..aInt64(9, _omitFieldNames ? '' : 'totalAmountPaise')
    ..aOS(10, _omitFieldNames ? '' : 'currency')
    ..aE<OrderStatus>(11, _omitFieldNames ? '' : 'status',
        enumValues: OrderStatus.values)
    ..aE<PaymentStatus>(12, _omitFieldNames ? '' : 'paymentStatus',
        enumValues: PaymentStatus.values)
    ..aOS(13, _omitFieldNames ? '' : 'paymentReference')
    ..aOS(14, _omitFieldNames ? '' : 'deliveryMethod')
    ..aOS(15, _omitFieldNames ? '' : 'deliveryAddress')
    ..aOS(16, _omitFieldNames ? '' : 'deliveryNotes')
    ..aOM<$0.Timestamp>(17, _omitFieldNames ? '' : 'estimatedDeliveryDate',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(18, _omitFieldNames ? '' : 'actualDeliveryDate',
        subBuilder: $0.Timestamp.create)
    ..aOS(19, _omitFieldNames ? '' : 'notes')
    ..aOS(20, _omitFieldNames ? '' : 'createdBy')
    ..aInt64(21, _omitFieldNames ? '' : 'version')
    ..aOM<$0.Timestamp>(22, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(23, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Order clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Order copyWith(void Function(Order) updates) =>
      super.copyWith((message) => updates(message as Order)) as Order;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Order create() => Order._();
  @$core.override
  Order createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Order getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Order>(create);
  static Order? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get tenantId => $_getSZ(1);
  @$pb.TagNumber(2)
  set tenantId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTenantId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTenantId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get listingId => $_getSZ(2);
  @$pb.TagNumber(3)
  set listingId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasListingId() => $_has(2);
  @$pb.TagNumber(3)
  void clearListingId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get buyerId => $_getSZ(3);
  @$pb.TagNumber(4)
  set buyerId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasBuyerId() => $_has(3);
  @$pb.TagNumber(4)
  void clearBuyerId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get sellerId => $_getSZ(4);
  @$pb.TagNumber(5)
  set sellerId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSellerId() => $_has(4);
  @$pb.TagNumber(5)
  void clearSellerId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get quantity => $_getN(5);
  @$pb.TagNumber(6)
  set quantity($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasQuantity() => $_has(5);
  @$pb.TagNumber(6)
  void clearQuantity() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get quantityUnit => $_getSZ(6);
  @$pb.TagNumber(7)
  set quantityUnit($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasQuantityUnit() => $_has(6);
  @$pb.TagNumber(7)
  void clearQuantityUnit() => $_clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get unitPricePaise => $_getI64(7);
  @$pb.TagNumber(8)
  set unitPricePaise($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasUnitPricePaise() => $_has(7);
  @$pb.TagNumber(8)
  void clearUnitPricePaise() => $_clearField(8);

  @$pb.TagNumber(9)
  $fixnum.Int64 get totalAmountPaise => $_getI64(8);
  @$pb.TagNumber(9)
  set totalAmountPaise($fixnum.Int64 value) => $_setInt64(8, value);
  @$pb.TagNumber(9)
  $core.bool hasTotalAmountPaise() => $_has(8);
  @$pb.TagNumber(9)
  void clearTotalAmountPaise() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get currency => $_getSZ(9);
  @$pb.TagNumber(10)
  set currency($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasCurrency() => $_has(9);
  @$pb.TagNumber(10)
  void clearCurrency() => $_clearField(10);

  @$pb.TagNumber(11)
  OrderStatus get status => $_getN(10);
  @$pb.TagNumber(11)
  set status(OrderStatus value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasStatus() => $_has(10);
  @$pb.TagNumber(11)
  void clearStatus() => $_clearField(11);

  @$pb.TagNumber(12)
  PaymentStatus get paymentStatus => $_getN(11);
  @$pb.TagNumber(12)
  set paymentStatus(PaymentStatus value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasPaymentStatus() => $_has(11);
  @$pb.TagNumber(12)
  void clearPaymentStatus() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get paymentReference => $_getSZ(12);
  @$pb.TagNumber(13)
  set paymentReference($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasPaymentReference() => $_has(12);
  @$pb.TagNumber(13)
  void clearPaymentReference() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.String get deliveryMethod => $_getSZ(13);
  @$pb.TagNumber(14)
  set deliveryMethod($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasDeliveryMethod() => $_has(13);
  @$pb.TagNumber(14)
  void clearDeliveryMethod() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.String get deliveryAddress => $_getSZ(14);
  @$pb.TagNumber(15)
  set deliveryAddress($core.String value) => $_setString(14, value);
  @$pb.TagNumber(15)
  $core.bool hasDeliveryAddress() => $_has(14);
  @$pb.TagNumber(15)
  void clearDeliveryAddress() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.String get deliveryNotes => $_getSZ(15);
  @$pb.TagNumber(16)
  set deliveryNotes($core.String value) => $_setString(15, value);
  @$pb.TagNumber(16)
  $core.bool hasDeliveryNotes() => $_has(15);
  @$pb.TagNumber(16)
  void clearDeliveryNotes() => $_clearField(16);

  @$pb.TagNumber(17)
  $0.Timestamp get estimatedDeliveryDate => $_getN(16);
  @$pb.TagNumber(17)
  set estimatedDeliveryDate($0.Timestamp value) => $_setField(17, value);
  @$pb.TagNumber(17)
  $core.bool hasEstimatedDeliveryDate() => $_has(16);
  @$pb.TagNumber(17)
  void clearEstimatedDeliveryDate() => $_clearField(17);
  @$pb.TagNumber(17)
  $0.Timestamp ensureEstimatedDeliveryDate() => $_ensure(16);

  @$pb.TagNumber(18)
  $0.Timestamp get actualDeliveryDate => $_getN(17);
  @$pb.TagNumber(18)
  set actualDeliveryDate($0.Timestamp value) => $_setField(18, value);
  @$pb.TagNumber(18)
  $core.bool hasActualDeliveryDate() => $_has(17);
  @$pb.TagNumber(18)
  void clearActualDeliveryDate() => $_clearField(18);
  @$pb.TagNumber(18)
  $0.Timestamp ensureActualDeliveryDate() => $_ensure(17);

  @$pb.TagNumber(19)
  $core.String get notes => $_getSZ(18);
  @$pb.TagNumber(19)
  set notes($core.String value) => $_setString(18, value);
  @$pb.TagNumber(19)
  $core.bool hasNotes() => $_has(18);
  @$pb.TagNumber(19)
  void clearNotes() => $_clearField(19);

  @$pb.TagNumber(20)
  $core.String get createdBy => $_getSZ(19);
  @$pb.TagNumber(20)
  set createdBy($core.String value) => $_setString(19, value);
  @$pb.TagNumber(20)
  $core.bool hasCreatedBy() => $_has(19);
  @$pb.TagNumber(20)
  void clearCreatedBy() => $_clearField(20);

  @$pb.TagNumber(21)
  $fixnum.Int64 get version => $_getI64(20);
  @$pb.TagNumber(21)
  set version($fixnum.Int64 value) => $_setInt64(20, value);
  @$pb.TagNumber(21)
  $core.bool hasVersion() => $_has(20);
  @$pb.TagNumber(21)
  void clearVersion() => $_clearField(21);

  @$pb.TagNumber(22)
  $0.Timestamp get createdAt => $_getN(21);
  @$pb.TagNumber(22)
  set createdAt($0.Timestamp value) => $_setField(22, value);
  @$pb.TagNumber(22)
  $core.bool hasCreatedAt() => $_has(21);
  @$pb.TagNumber(22)
  void clearCreatedAt() => $_clearField(22);
  @$pb.TagNumber(22)
  $0.Timestamp ensureCreatedAt() => $_ensure(21);

  @$pb.TagNumber(23)
  $0.Timestamp get updatedAt => $_getN(22);
  @$pb.TagNumber(23)
  set updatedAt($0.Timestamp value) => $_setField(23, value);
  @$pb.TagNumber(23)
  $core.bool hasUpdatedAt() => $_has(22);
  @$pb.TagNumber(23)
  void clearUpdatedAt() => $_clearField(23);
  @$pb.TagNumber(23)
  $0.Timestamp ensureUpdatedAt() => $_ensure(22);
}

class CreateListingRequest extends $pb.GeneratedMessage {
  factory CreateListingRequest({
    $core.String? farmId,
    $core.String? cropId,
    $core.String? productName,
    $core.String? productType,
    $core.String? description,
    $core.double? quantityAvailable,
    $core.String? quantityUnit,
    $fixnum.Int64? pricePerUnitPaise,
    $core.String? currency,
    $core.double? minOrderQuantity,
    $core.String? qualityGrade,
    $core.String? traceabilityRecordId,
    $core.String? location,
    $core.String? region,
    $core.Iterable<$core.String>? imageUrls,
    $0.Timestamp? availableFrom,
    $0.Timestamp? availableTo,
    $core.String? batchId,
  }) {
    final result = create();
    if (farmId != null) result.farmId = farmId;
    if (cropId != null) result.cropId = cropId;
    if (productName != null) result.productName = productName;
    if (productType != null) result.productType = productType;
    if (description != null) result.description = description;
    if (quantityAvailable != null) result.quantityAvailable = quantityAvailable;
    if (quantityUnit != null) result.quantityUnit = quantityUnit;
    if (pricePerUnitPaise != null) result.pricePerUnitPaise = pricePerUnitPaise;
    if (currency != null) result.currency = currency;
    if (minOrderQuantity != null) result.minOrderQuantity = minOrderQuantity;
    if (qualityGrade != null) result.qualityGrade = qualityGrade;
    if (traceabilityRecordId != null)
      result.traceabilityRecordId = traceabilityRecordId;
    if (location != null) result.location = location;
    if (region != null) result.region = region;
    if (imageUrls != null) result.imageUrls.addAll(imageUrls);
    if (availableFrom != null) result.availableFrom = availableFrom;
    if (availableTo != null) result.availableTo = availableTo;
    if (batchId != null) result.batchId = batchId;
    return result;
  }

  CreateListingRequest._();

  factory CreateListingRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateListingRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateListingRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.commerce.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'farmId')
    ..aOS(2, _omitFieldNames ? '' : 'cropId')
    ..aOS(3, _omitFieldNames ? '' : 'productName')
    ..aOS(4, _omitFieldNames ? '' : 'productType')
    ..aOS(5, _omitFieldNames ? '' : 'description')
    ..aD(6, _omitFieldNames ? '' : 'quantityAvailable')
    ..aOS(7, _omitFieldNames ? '' : 'quantityUnit')
    ..aInt64(8, _omitFieldNames ? '' : 'pricePerUnitPaise')
    ..aOS(9, _omitFieldNames ? '' : 'currency')
    ..aD(10, _omitFieldNames ? '' : 'minOrderQuantity')
    ..aOS(11, _omitFieldNames ? '' : 'qualityGrade')
    ..aOS(12, _omitFieldNames ? '' : 'traceabilityRecordId')
    ..aOS(13, _omitFieldNames ? '' : 'location')
    ..aOS(14, _omitFieldNames ? '' : 'region')
    ..pPS(15, _omitFieldNames ? '' : 'imageUrls')
    ..aOM<$0.Timestamp>(16, _omitFieldNames ? '' : 'availableFrom',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(17, _omitFieldNames ? '' : 'availableTo',
        subBuilder: $0.Timestamp.create)
    ..aOS(18, _omitFieldNames ? '' : 'batchId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateListingRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateListingRequest copyWith(void Function(CreateListingRequest) updates) =>
      super.copyWith((message) => updates(message as CreateListingRequest))
          as CreateListingRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateListingRequest create() => CreateListingRequest._();
  @$core.override
  CreateListingRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateListingRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateListingRequest>(create);
  static CreateListingRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get farmId => $_getSZ(0);
  @$pb.TagNumber(1)
  set farmId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFarmId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFarmId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get cropId => $_getSZ(1);
  @$pb.TagNumber(2)
  set cropId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCropId() => $_has(1);
  @$pb.TagNumber(2)
  void clearCropId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get productName => $_getSZ(2);
  @$pb.TagNumber(3)
  set productName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasProductName() => $_has(2);
  @$pb.TagNumber(3)
  void clearProductName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get productType => $_getSZ(3);
  @$pb.TagNumber(4)
  set productType($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasProductType() => $_has(3);
  @$pb.TagNumber(4)
  void clearProductType() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get description => $_getSZ(4);
  @$pb.TagNumber(5)
  set description($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDescription() => $_has(4);
  @$pb.TagNumber(5)
  void clearDescription() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get quantityAvailable => $_getN(5);
  @$pb.TagNumber(6)
  set quantityAvailable($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasQuantityAvailable() => $_has(5);
  @$pb.TagNumber(6)
  void clearQuantityAvailable() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get quantityUnit => $_getSZ(6);
  @$pb.TagNumber(7)
  set quantityUnit($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasQuantityUnit() => $_has(6);
  @$pb.TagNumber(7)
  void clearQuantityUnit() => $_clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get pricePerUnitPaise => $_getI64(7);
  @$pb.TagNumber(8)
  set pricePerUnitPaise($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasPricePerUnitPaise() => $_has(7);
  @$pb.TagNumber(8)
  void clearPricePerUnitPaise() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get currency => $_getSZ(8);
  @$pb.TagNumber(9)
  set currency($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasCurrency() => $_has(8);
  @$pb.TagNumber(9)
  void clearCurrency() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.double get minOrderQuantity => $_getN(9);
  @$pb.TagNumber(10)
  set minOrderQuantity($core.double value) => $_setDouble(9, value);
  @$pb.TagNumber(10)
  $core.bool hasMinOrderQuantity() => $_has(9);
  @$pb.TagNumber(10)
  void clearMinOrderQuantity() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get qualityGrade => $_getSZ(10);
  @$pb.TagNumber(11)
  set qualityGrade($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasQualityGrade() => $_has(10);
  @$pb.TagNumber(11)
  void clearQualityGrade() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get traceabilityRecordId => $_getSZ(11);
  @$pb.TagNumber(12)
  set traceabilityRecordId($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasTraceabilityRecordId() => $_has(11);
  @$pb.TagNumber(12)
  void clearTraceabilityRecordId() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get location => $_getSZ(12);
  @$pb.TagNumber(13)
  set location($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasLocation() => $_has(12);
  @$pb.TagNumber(13)
  void clearLocation() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.String get region => $_getSZ(13);
  @$pb.TagNumber(14)
  set region($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasRegion() => $_has(13);
  @$pb.TagNumber(14)
  void clearRegion() => $_clearField(14);

  @$pb.TagNumber(15)
  $pb.PbList<$core.String> get imageUrls => $_getList(14);

  @$pb.TagNumber(16)
  $0.Timestamp get availableFrom => $_getN(15);
  @$pb.TagNumber(16)
  set availableFrom($0.Timestamp value) => $_setField(16, value);
  @$pb.TagNumber(16)
  $core.bool hasAvailableFrom() => $_has(15);
  @$pb.TagNumber(16)
  void clearAvailableFrom() => $_clearField(16);
  @$pb.TagNumber(16)
  $0.Timestamp ensureAvailableFrom() => $_ensure(15);

  @$pb.TagNumber(17)
  $0.Timestamp get availableTo => $_getN(16);
  @$pb.TagNumber(17)
  set availableTo($0.Timestamp value) => $_setField(17, value);
  @$pb.TagNumber(17)
  $core.bool hasAvailableTo() => $_has(16);
  @$pb.TagNumber(17)
  void clearAvailableTo() => $_clearField(17);
  @$pb.TagNumber(17)
  $0.Timestamp ensureAvailableTo() => $_ensure(16);

  @$pb.TagNumber(18)
  $core.String get batchId => $_getSZ(17);
  @$pb.TagNumber(18)
  set batchId($core.String value) => $_setString(17, value);
  @$pb.TagNumber(18)
  $core.bool hasBatchId() => $_has(17);
  @$pb.TagNumber(18)
  void clearBatchId() => $_clearField(18);
}

class CreateListingResponse extends $pb.GeneratedMessage {
  factory CreateListingResponse({
    MarketplaceListing? listing,
  }) {
    final result = create();
    if (listing != null) result.listing = listing;
    return result;
  }

  CreateListingResponse._();

  factory CreateListingResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateListingResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateListingResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.commerce.v1'),
      createEmptyInstance: create)
    ..aOM<MarketplaceListing>(1, _omitFieldNames ? '' : 'listing',
        subBuilder: MarketplaceListing.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateListingResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateListingResponse copyWith(
          void Function(CreateListingResponse) updates) =>
      super.copyWith((message) => updates(message as CreateListingResponse))
          as CreateListingResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateListingResponse create() => CreateListingResponse._();
  @$core.override
  CreateListingResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateListingResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateListingResponse>(create);
  static CreateListingResponse? _defaultInstance;

  @$pb.TagNumber(1)
  MarketplaceListing get listing => $_getN(0);
  @$pb.TagNumber(1)
  set listing(MarketplaceListing value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasListing() => $_has(0);
  @$pb.TagNumber(1)
  void clearListing() => $_clearField(1);
  @$pb.TagNumber(1)
  MarketplaceListing ensureListing() => $_ensure(0);
}

class GetListingRequest extends $pb.GeneratedMessage {
  factory GetListingRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  GetListingRequest._();

  factory GetListingRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetListingRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetListingRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.commerce.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetListingRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetListingRequest copyWith(void Function(GetListingRequest) updates) =>
      super.copyWith((message) => updates(message as GetListingRequest))
          as GetListingRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetListingRequest create() => GetListingRequest._();
  @$core.override
  GetListingRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetListingRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetListingRequest>(create);
  static GetListingRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class GetListingResponse extends $pb.GeneratedMessage {
  factory GetListingResponse({
    MarketplaceListing? listing,
  }) {
    final result = create();
    if (listing != null) result.listing = listing;
    return result;
  }

  GetListingResponse._();

  factory GetListingResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetListingResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetListingResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.commerce.v1'),
      createEmptyInstance: create)
    ..aOM<MarketplaceListing>(1, _omitFieldNames ? '' : 'listing',
        subBuilder: MarketplaceListing.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetListingResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetListingResponse copyWith(void Function(GetListingResponse) updates) =>
      super.copyWith((message) => updates(message as GetListingResponse))
          as GetListingResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetListingResponse create() => GetListingResponse._();
  @$core.override
  GetListingResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetListingResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetListingResponse>(create);
  static GetListingResponse? _defaultInstance;

  @$pb.TagNumber(1)
  MarketplaceListing get listing => $_getN(0);
  @$pb.TagNumber(1)
  set listing(MarketplaceListing value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasListing() => $_has(0);
  @$pb.TagNumber(1)
  void clearListing() => $_clearField(1);
  @$pb.TagNumber(1)
  MarketplaceListing ensureListing() => $_ensure(0);
}

class ListListingsRequest extends $pb.GeneratedMessage {
  factory ListListingsRequest({
    $core.String? farmId,
    $core.String? cropId,
    $core.String? productType,
    $core.String? region,
    ListingStatus? status,
    $core.String? search,
    $core.int? pageSize,
    $core.int? pageOffset,
  }) {
    final result = create();
    if (farmId != null) result.farmId = farmId;
    if (cropId != null) result.cropId = cropId;
    if (productType != null) result.productType = productType;
    if (region != null) result.region = region;
    if (status != null) result.status = status;
    if (search != null) result.search = search;
    if (pageSize != null) result.pageSize = pageSize;
    if (pageOffset != null) result.pageOffset = pageOffset;
    return result;
  }

  ListListingsRequest._();

  factory ListListingsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListListingsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListListingsRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.commerce.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'farmId')
    ..aOS(2, _omitFieldNames ? '' : 'cropId')
    ..aOS(3, _omitFieldNames ? '' : 'productType')
    ..aOS(4, _omitFieldNames ? '' : 'region')
    ..aE<ListingStatus>(5, _omitFieldNames ? '' : 'status',
        enumValues: ListingStatus.values)
    ..aOS(6, _omitFieldNames ? '' : 'search')
    ..aI(7, _omitFieldNames ? '' : 'pageSize')
    ..aI(8, _omitFieldNames ? '' : 'pageOffset')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListListingsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListListingsRequest copyWith(void Function(ListListingsRequest) updates) =>
      super.copyWith((message) => updates(message as ListListingsRequest))
          as ListListingsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListListingsRequest create() => ListListingsRequest._();
  @$core.override
  ListListingsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListListingsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListListingsRequest>(create);
  static ListListingsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get farmId => $_getSZ(0);
  @$pb.TagNumber(1)
  set farmId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFarmId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFarmId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get cropId => $_getSZ(1);
  @$pb.TagNumber(2)
  set cropId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCropId() => $_has(1);
  @$pb.TagNumber(2)
  void clearCropId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get productType => $_getSZ(2);
  @$pb.TagNumber(3)
  set productType($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasProductType() => $_has(2);
  @$pb.TagNumber(3)
  void clearProductType() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get region => $_getSZ(3);
  @$pb.TagNumber(4)
  set region($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRegion() => $_has(3);
  @$pb.TagNumber(4)
  void clearRegion() => $_clearField(4);

  @$pb.TagNumber(5)
  ListingStatus get status => $_getN(4);
  @$pb.TagNumber(5)
  set status(ListingStatus value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(4);
  @$pb.TagNumber(5)
  void clearStatus() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get search => $_getSZ(5);
  @$pb.TagNumber(6)
  set search($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSearch() => $_has(5);
  @$pb.TagNumber(6)
  void clearSearch() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get pageSize => $_getIZ(6);
  @$pb.TagNumber(7)
  set pageSize($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasPageSize() => $_has(6);
  @$pb.TagNumber(7)
  void clearPageSize() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get pageOffset => $_getIZ(7);
  @$pb.TagNumber(8)
  set pageOffset($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasPageOffset() => $_has(7);
  @$pb.TagNumber(8)
  void clearPageOffset() => $_clearField(8);
}

class ListListingsResponse extends $pb.GeneratedMessage {
  factory ListListingsResponse({
    $core.Iterable<MarketplaceListing>? listings,
    $core.int? totalCount,
  }) {
    final result = create();
    if (listings != null) result.listings.addAll(listings);
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListListingsResponse._();

  factory ListListingsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListListingsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListListingsResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.commerce.v1'),
      createEmptyInstance: create)
    ..pPM<MarketplaceListing>(1, _omitFieldNames ? '' : 'listings',
        subBuilder: MarketplaceListing.create)
    ..aI(2, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListListingsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListListingsResponse copyWith(void Function(ListListingsResponse) updates) =>
      super.copyWith((message) => updates(message as ListListingsResponse))
          as ListListingsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListListingsResponse create() => ListListingsResponse._();
  @$core.override
  ListListingsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListListingsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListListingsResponse>(create);
  static ListListingsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<MarketplaceListing> get listings => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get totalCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalCount() => $_clearField(2);
}

class UpdateListingRequest extends $pb.GeneratedMessage {
  factory UpdateListingRequest({
    $core.String? id,
    $core.String? productName,
    $core.String? description,
    $core.double? quantityAvailable,
    $fixnum.Int64? pricePerUnitPaise,
    $core.double? minOrderQuantity,
    $core.String? qualityGrade,
    $core.Iterable<$core.String>? imageUrls,
    $0.Timestamp? availableTo,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (productName != null) result.productName = productName;
    if (description != null) result.description = description;
    if (quantityAvailable != null) result.quantityAvailable = quantityAvailable;
    if (pricePerUnitPaise != null) result.pricePerUnitPaise = pricePerUnitPaise;
    if (minOrderQuantity != null) result.minOrderQuantity = minOrderQuantity;
    if (qualityGrade != null) result.qualityGrade = qualityGrade;
    if (imageUrls != null) result.imageUrls.addAll(imageUrls);
    if (availableTo != null) result.availableTo = availableTo;
    return result;
  }

  UpdateListingRequest._();

  factory UpdateListingRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateListingRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateListingRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.commerce.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'productName')
    ..aOS(3, _omitFieldNames ? '' : 'description')
    ..aD(4, _omitFieldNames ? '' : 'quantityAvailable')
    ..aInt64(5, _omitFieldNames ? '' : 'pricePerUnitPaise')
    ..aD(6, _omitFieldNames ? '' : 'minOrderQuantity')
    ..aOS(7, _omitFieldNames ? '' : 'qualityGrade')
    ..pPS(8, _omitFieldNames ? '' : 'imageUrls')
    ..aOM<$0.Timestamp>(9, _omitFieldNames ? '' : 'availableTo',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateListingRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateListingRequest copyWith(void Function(UpdateListingRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateListingRequest))
          as UpdateListingRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateListingRequest create() => UpdateListingRequest._();
  @$core.override
  UpdateListingRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateListingRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateListingRequest>(create);
  static UpdateListingRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get productName => $_getSZ(1);
  @$pb.TagNumber(2)
  set productName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasProductName() => $_has(1);
  @$pb.TagNumber(2)
  void clearProductName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get description => $_getSZ(2);
  @$pb.TagNumber(3)
  set description($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDescription() => $_has(2);
  @$pb.TagNumber(3)
  void clearDescription() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get quantityAvailable => $_getN(3);
  @$pb.TagNumber(4)
  set quantityAvailable($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasQuantityAvailable() => $_has(3);
  @$pb.TagNumber(4)
  void clearQuantityAvailable() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get pricePerUnitPaise => $_getI64(4);
  @$pb.TagNumber(5)
  set pricePerUnitPaise($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPricePerUnitPaise() => $_has(4);
  @$pb.TagNumber(5)
  void clearPricePerUnitPaise() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get minOrderQuantity => $_getN(5);
  @$pb.TagNumber(6)
  set minOrderQuantity($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMinOrderQuantity() => $_has(5);
  @$pb.TagNumber(6)
  void clearMinOrderQuantity() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get qualityGrade => $_getSZ(6);
  @$pb.TagNumber(7)
  set qualityGrade($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasQualityGrade() => $_has(6);
  @$pb.TagNumber(7)
  void clearQualityGrade() => $_clearField(7);

  @$pb.TagNumber(8)
  $pb.PbList<$core.String> get imageUrls => $_getList(7);

  @$pb.TagNumber(9)
  $0.Timestamp get availableTo => $_getN(8);
  @$pb.TagNumber(9)
  set availableTo($0.Timestamp value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasAvailableTo() => $_has(8);
  @$pb.TagNumber(9)
  void clearAvailableTo() => $_clearField(9);
  @$pb.TagNumber(9)
  $0.Timestamp ensureAvailableTo() => $_ensure(8);
}

class UpdateListingResponse extends $pb.GeneratedMessage {
  factory UpdateListingResponse({
    MarketplaceListing? listing,
  }) {
    final result = create();
    if (listing != null) result.listing = listing;
    return result;
  }

  UpdateListingResponse._();

  factory UpdateListingResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateListingResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateListingResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.commerce.v1'),
      createEmptyInstance: create)
    ..aOM<MarketplaceListing>(1, _omitFieldNames ? '' : 'listing',
        subBuilder: MarketplaceListing.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateListingResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateListingResponse copyWith(
          void Function(UpdateListingResponse) updates) =>
      super.copyWith((message) => updates(message as UpdateListingResponse))
          as UpdateListingResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateListingResponse create() => UpdateListingResponse._();
  @$core.override
  UpdateListingResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateListingResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateListingResponse>(create);
  static UpdateListingResponse? _defaultInstance;

  @$pb.TagNumber(1)
  MarketplaceListing get listing => $_getN(0);
  @$pb.TagNumber(1)
  set listing(MarketplaceListing value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasListing() => $_has(0);
  @$pb.TagNumber(1)
  void clearListing() => $_clearField(1);
  @$pb.TagNumber(1)
  MarketplaceListing ensureListing() => $_ensure(0);
}

class ActivateListingRequest extends $pb.GeneratedMessage {
  factory ActivateListingRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  ActivateListingRequest._();

  factory ActivateListingRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ActivateListingRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ActivateListingRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.commerce.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActivateListingRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActivateListingRequest copyWith(
          void Function(ActivateListingRequest) updates) =>
      super.copyWith((message) => updates(message as ActivateListingRequest))
          as ActivateListingRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ActivateListingRequest create() => ActivateListingRequest._();
  @$core.override
  ActivateListingRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ActivateListingRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ActivateListingRequest>(create);
  static ActivateListingRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class ActivateListingResponse extends $pb.GeneratedMessage {
  factory ActivateListingResponse({
    MarketplaceListing? listing,
  }) {
    final result = create();
    if (listing != null) result.listing = listing;
    return result;
  }

  ActivateListingResponse._();

  factory ActivateListingResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ActivateListingResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ActivateListingResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.commerce.v1'),
      createEmptyInstance: create)
    ..aOM<MarketplaceListing>(1, _omitFieldNames ? '' : 'listing',
        subBuilder: MarketplaceListing.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActivateListingResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActivateListingResponse copyWith(
          void Function(ActivateListingResponse) updates) =>
      super.copyWith((message) => updates(message as ActivateListingResponse))
          as ActivateListingResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ActivateListingResponse create() => ActivateListingResponse._();
  @$core.override
  ActivateListingResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ActivateListingResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ActivateListingResponse>(create);
  static ActivateListingResponse? _defaultInstance;

  @$pb.TagNumber(1)
  MarketplaceListing get listing => $_getN(0);
  @$pb.TagNumber(1)
  set listing(MarketplaceListing value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasListing() => $_has(0);
  @$pb.TagNumber(1)
  void clearListing() => $_clearField(1);
  @$pb.TagNumber(1)
  MarketplaceListing ensureListing() => $_ensure(0);
}

class CancelListingRequest extends $pb.GeneratedMessage {
  factory CancelListingRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  CancelListingRequest._();

  factory CancelListingRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CancelListingRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CancelListingRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.commerce.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CancelListingRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CancelListingRequest copyWith(void Function(CancelListingRequest) updates) =>
      super.copyWith((message) => updates(message as CancelListingRequest))
          as CancelListingRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CancelListingRequest create() => CancelListingRequest._();
  @$core.override
  CancelListingRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CancelListingRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CancelListingRequest>(create);
  static CancelListingRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class CancelListingResponse extends $pb.GeneratedMessage {
  factory CancelListingResponse({
    MarketplaceListing? listing,
  }) {
    final result = create();
    if (listing != null) result.listing = listing;
    return result;
  }

  CancelListingResponse._();

  factory CancelListingResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CancelListingResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CancelListingResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.commerce.v1'),
      createEmptyInstance: create)
    ..aOM<MarketplaceListing>(1, _omitFieldNames ? '' : 'listing',
        subBuilder: MarketplaceListing.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CancelListingResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CancelListingResponse copyWith(
          void Function(CancelListingResponse) updates) =>
      super.copyWith((message) => updates(message as CancelListingResponse))
          as CancelListingResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CancelListingResponse create() => CancelListingResponse._();
  @$core.override
  CancelListingResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CancelListingResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CancelListingResponse>(create);
  static CancelListingResponse? _defaultInstance;

  @$pb.TagNumber(1)
  MarketplaceListing get listing => $_getN(0);
  @$pb.TagNumber(1)
  set listing(MarketplaceListing value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasListing() => $_has(0);
  @$pb.TagNumber(1)
  void clearListing() => $_clearField(1);
  @$pb.TagNumber(1)
  MarketplaceListing ensureListing() => $_ensure(0);
}

class PlaceOrderRequest extends $pb.GeneratedMessage {
  factory PlaceOrderRequest({
    $core.String? listingId,
    $core.double? quantity,
    $core.String? deliveryMethod,
    $core.String? deliveryAddress,
    $core.String? deliveryNotes,
    $core.String? notes,
  }) {
    final result = create();
    if (listingId != null) result.listingId = listingId;
    if (quantity != null) result.quantity = quantity;
    if (deliveryMethod != null) result.deliveryMethod = deliveryMethod;
    if (deliveryAddress != null) result.deliveryAddress = deliveryAddress;
    if (deliveryNotes != null) result.deliveryNotes = deliveryNotes;
    if (notes != null) result.notes = notes;
    return result;
  }

  PlaceOrderRequest._();

  factory PlaceOrderRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PlaceOrderRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PlaceOrderRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.commerce.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'listingId')
    ..aD(2, _omitFieldNames ? '' : 'quantity')
    ..aOS(3, _omitFieldNames ? '' : 'deliveryMethod')
    ..aOS(4, _omitFieldNames ? '' : 'deliveryAddress')
    ..aOS(5, _omitFieldNames ? '' : 'deliveryNotes')
    ..aOS(6, _omitFieldNames ? '' : 'notes')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PlaceOrderRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PlaceOrderRequest copyWith(void Function(PlaceOrderRequest) updates) =>
      super.copyWith((message) => updates(message as PlaceOrderRequest))
          as PlaceOrderRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PlaceOrderRequest create() => PlaceOrderRequest._();
  @$core.override
  PlaceOrderRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PlaceOrderRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PlaceOrderRequest>(create);
  static PlaceOrderRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get listingId => $_getSZ(0);
  @$pb.TagNumber(1)
  set listingId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasListingId() => $_has(0);
  @$pb.TagNumber(1)
  void clearListingId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get quantity => $_getN(1);
  @$pb.TagNumber(2)
  set quantity($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasQuantity() => $_has(1);
  @$pb.TagNumber(2)
  void clearQuantity() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get deliveryMethod => $_getSZ(2);
  @$pb.TagNumber(3)
  set deliveryMethod($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDeliveryMethod() => $_has(2);
  @$pb.TagNumber(3)
  void clearDeliveryMethod() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get deliveryAddress => $_getSZ(3);
  @$pb.TagNumber(4)
  set deliveryAddress($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDeliveryAddress() => $_has(3);
  @$pb.TagNumber(4)
  void clearDeliveryAddress() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get deliveryNotes => $_getSZ(4);
  @$pb.TagNumber(5)
  set deliveryNotes($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDeliveryNotes() => $_has(4);
  @$pb.TagNumber(5)
  void clearDeliveryNotes() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get notes => $_getSZ(5);
  @$pb.TagNumber(6)
  set notes($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasNotes() => $_has(5);
  @$pb.TagNumber(6)
  void clearNotes() => $_clearField(6);
}

class PlaceOrderResponse extends $pb.GeneratedMessage {
  factory PlaceOrderResponse({
    Order? order,
  }) {
    final result = create();
    if (order != null) result.order = order;
    return result;
  }

  PlaceOrderResponse._();

  factory PlaceOrderResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PlaceOrderResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PlaceOrderResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.commerce.v1'),
      createEmptyInstance: create)
    ..aOM<Order>(1, _omitFieldNames ? '' : 'order', subBuilder: Order.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PlaceOrderResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PlaceOrderResponse copyWith(void Function(PlaceOrderResponse) updates) =>
      super.copyWith((message) => updates(message as PlaceOrderResponse))
          as PlaceOrderResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PlaceOrderResponse create() => PlaceOrderResponse._();
  @$core.override
  PlaceOrderResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PlaceOrderResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PlaceOrderResponse>(create);
  static PlaceOrderResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Order get order => $_getN(0);
  @$pb.TagNumber(1)
  set order(Order value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasOrder() => $_has(0);
  @$pb.TagNumber(1)
  void clearOrder() => $_clearField(1);
  @$pb.TagNumber(1)
  Order ensureOrder() => $_ensure(0);
}

class GetOrderRequest extends $pb.GeneratedMessage {
  factory GetOrderRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  GetOrderRequest._();

  factory GetOrderRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetOrderRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetOrderRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.commerce.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetOrderRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetOrderRequest copyWith(void Function(GetOrderRequest) updates) =>
      super.copyWith((message) => updates(message as GetOrderRequest))
          as GetOrderRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetOrderRequest create() => GetOrderRequest._();
  @$core.override
  GetOrderRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetOrderRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetOrderRequest>(create);
  static GetOrderRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class GetOrderResponse extends $pb.GeneratedMessage {
  factory GetOrderResponse({
    Order? order,
  }) {
    final result = create();
    if (order != null) result.order = order;
    return result;
  }

  GetOrderResponse._();

  factory GetOrderResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetOrderResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetOrderResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.commerce.v1'),
      createEmptyInstance: create)
    ..aOM<Order>(1, _omitFieldNames ? '' : 'order', subBuilder: Order.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetOrderResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetOrderResponse copyWith(void Function(GetOrderResponse) updates) =>
      super.copyWith((message) => updates(message as GetOrderResponse))
          as GetOrderResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetOrderResponse create() => GetOrderResponse._();
  @$core.override
  GetOrderResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetOrderResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetOrderResponse>(create);
  static GetOrderResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Order get order => $_getN(0);
  @$pb.TagNumber(1)
  set order(Order value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasOrder() => $_has(0);
  @$pb.TagNumber(1)
  void clearOrder() => $_clearField(1);
  @$pb.TagNumber(1)
  Order ensureOrder() => $_ensure(0);
}

class ListOrdersRequest extends $pb.GeneratedMessage {
  factory ListOrdersRequest({
    $core.String? listingId,
    $core.String? buyerId,
    $core.String? sellerId,
    OrderStatus? status,
    $core.int? pageSize,
    $core.int? pageOffset,
  }) {
    final result = create();
    if (listingId != null) result.listingId = listingId;
    if (buyerId != null) result.buyerId = buyerId;
    if (sellerId != null) result.sellerId = sellerId;
    if (status != null) result.status = status;
    if (pageSize != null) result.pageSize = pageSize;
    if (pageOffset != null) result.pageOffset = pageOffset;
    return result;
  }

  ListOrdersRequest._();

  factory ListOrdersRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListOrdersRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListOrdersRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.commerce.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'listingId')
    ..aOS(2, _omitFieldNames ? '' : 'buyerId')
    ..aOS(3, _omitFieldNames ? '' : 'sellerId')
    ..aE<OrderStatus>(4, _omitFieldNames ? '' : 'status',
        enumValues: OrderStatus.values)
    ..aI(5, _omitFieldNames ? '' : 'pageSize')
    ..aI(6, _omitFieldNames ? '' : 'pageOffset')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListOrdersRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListOrdersRequest copyWith(void Function(ListOrdersRequest) updates) =>
      super.copyWith((message) => updates(message as ListOrdersRequest))
          as ListOrdersRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListOrdersRequest create() => ListOrdersRequest._();
  @$core.override
  ListOrdersRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListOrdersRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListOrdersRequest>(create);
  static ListOrdersRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get listingId => $_getSZ(0);
  @$pb.TagNumber(1)
  set listingId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasListingId() => $_has(0);
  @$pb.TagNumber(1)
  void clearListingId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get buyerId => $_getSZ(1);
  @$pb.TagNumber(2)
  set buyerId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBuyerId() => $_has(1);
  @$pb.TagNumber(2)
  void clearBuyerId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get sellerId => $_getSZ(2);
  @$pb.TagNumber(3)
  set sellerId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSellerId() => $_has(2);
  @$pb.TagNumber(3)
  void clearSellerId() => $_clearField(3);

  @$pb.TagNumber(4)
  OrderStatus get status => $_getN(3);
  @$pb.TagNumber(4)
  set status(OrderStatus value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasStatus() => $_has(3);
  @$pb.TagNumber(4)
  void clearStatus() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get pageSize => $_getIZ(4);
  @$pb.TagNumber(5)
  set pageSize($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPageSize() => $_has(4);
  @$pb.TagNumber(5)
  void clearPageSize() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get pageOffset => $_getIZ(5);
  @$pb.TagNumber(6)
  set pageOffset($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPageOffset() => $_has(5);
  @$pb.TagNumber(6)
  void clearPageOffset() => $_clearField(6);
}

class ListOrdersResponse extends $pb.GeneratedMessage {
  factory ListOrdersResponse({
    $core.Iterable<Order>? orders,
    $core.int? totalCount,
  }) {
    final result = create();
    if (orders != null) result.orders.addAll(orders);
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListOrdersResponse._();

  factory ListOrdersResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListOrdersResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListOrdersResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.commerce.v1'),
      createEmptyInstance: create)
    ..pPM<Order>(1, _omitFieldNames ? '' : 'orders', subBuilder: Order.create)
    ..aI(2, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListOrdersResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListOrdersResponse copyWith(void Function(ListOrdersResponse) updates) =>
      super.copyWith((message) => updates(message as ListOrdersResponse))
          as ListOrdersResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListOrdersResponse create() => ListOrdersResponse._();
  @$core.override
  ListOrdersResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListOrdersResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListOrdersResponse>(create);
  static ListOrdersResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Order> get orders => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get totalCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalCount() => $_clearField(2);
}

class UpdateOrderStatusRequest extends $pb.GeneratedMessage {
  factory UpdateOrderStatusRequest({
    $core.String? id,
    OrderStatus? status,
    $core.String? notes,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (status != null) result.status = status;
    if (notes != null) result.notes = notes;
    return result;
  }

  UpdateOrderStatusRequest._();

  factory UpdateOrderStatusRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateOrderStatusRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateOrderStatusRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.commerce.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aE<OrderStatus>(2, _omitFieldNames ? '' : 'status',
        enumValues: OrderStatus.values)
    ..aOS(3, _omitFieldNames ? '' : 'notes')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateOrderStatusRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateOrderStatusRequest copyWith(
          void Function(UpdateOrderStatusRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateOrderStatusRequest))
          as UpdateOrderStatusRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateOrderStatusRequest create() => UpdateOrderStatusRequest._();
  @$core.override
  UpdateOrderStatusRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateOrderStatusRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateOrderStatusRequest>(create);
  static UpdateOrderStatusRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  OrderStatus get status => $_getN(1);
  @$pb.TagNumber(2)
  set status(OrderStatus value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get notes => $_getSZ(2);
  @$pb.TagNumber(3)
  set notes($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNotes() => $_has(2);
  @$pb.TagNumber(3)
  void clearNotes() => $_clearField(3);
}

class UpdateOrderStatusResponse extends $pb.GeneratedMessage {
  factory UpdateOrderStatusResponse({
    Order? order,
  }) {
    final result = create();
    if (order != null) result.order = order;
    return result;
  }

  UpdateOrderStatusResponse._();

  factory UpdateOrderStatusResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateOrderStatusResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateOrderStatusResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.commerce.v1'),
      createEmptyInstance: create)
    ..aOM<Order>(1, _omitFieldNames ? '' : 'order', subBuilder: Order.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateOrderStatusResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateOrderStatusResponse copyWith(
          void Function(UpdateOrderStatusResponse) updates) =>
      super.copyWith((message) => updates(message as UpdateOrderStatusResponse))
          as UpdateOrderStatusResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateOrderStatusResponse create() => UpdateOrderStatusResponse._();
  @$core.override
  UpdateOrderStatusResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateOrderStatusResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateOrderStatusResponse>(create);
  static UpdateOrderStatusResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Order get order => $_getN(0);
  @$pb.TagNumber(1)
  set order(Order value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasOrder() => $_has(0);
  @$pb.TagNumber(1)
  void clearOrder() => $_clearField(1);
  @$pb.TagNumber(1)
  Order ensureOrder() => $_ensure(0);
}

class UpdatePaymentStatusRequest extends $pb.GeneratedMessage {
  factory UpdatePaymentStatusRequest({
    $core.String? id,
    PaymentStatus? paymentStatus,
    $core.String? paymentReference,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (paymentStatus != null) result.paymentStatus = paymentStatus;
    if (paymentReference != null) result.paymentReference = paymentReference;
    return result;
  }

  UpdatePaymentStatusRequest._();

  factory UpdatePaymentStatusRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdatePaymentStatusRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdatePaymentStatusRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.commerce.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aE<PaymentStatus>(2, _omitFieldNames ? '' : 'paymentStatus',
        enumValues: PaymentStatus.values)
    ..aOS(3, _omitFieldNames ? '' : 'paymentReference')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdatePaymentStatusRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdatePaymentStatusRequest copyWith(
          void Function(UpdatePaymentStatusRequest) updates) =>
      super.copyWith(
              (message) => updates(message as UpdatePaymentStatusRequest))
          as UpdatePaymentStatusRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdatePaymentStatusRequest create() => UpdatePaymentStatusRequest._();
  @$core.override
  UpdatePaymentStatusRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdatePaymentStatusRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdatePaymentStatusRequest>(create);
  static UpdatePaymentStatusRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  PaymentStatus get paymentStatus => $_getN(1);
  @$pb.TagNumber(2)
  set paymentStatus(PaymentStatus value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasPaymentStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearPaymentStatus() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get paymentReference => $_getSZ(2);
  @$pb.TagNumber(3)
  set paymentReference($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPaymentReference() => $_has(2);
  @$pb.TagNumber(3)
  void clearPaymentReference() => $_clearField(3);
}

class UpdatePaymentStatusResponse extends $pb.GeneratedMessage {
  factory UpdatePaymentStatusResponse({
    Order? order,
  }) {
    final result = create();
    if (order != null) result.order = order;
    return result;
  }

  UpdatePaymentStatusResponse._();

  factory UpdatePaymentStatusResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdatePaymentStatusResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdatePaymentStatusResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.commerce.v1'),
      createEmptyInstance: create)
    ..aOM<Order>(1, _omitFieldNames ? '' : 'order', subBuilder: Order.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdatePaymentStatusResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdatePaymentStatusResponse copyWith(
          void Function(UpdatePaymentStatusResponse) updates) =>
      super.copyWith(
              (message) => updates(message as UpdatePaymentStatusResponse))
          as UpdatePaymentStatusResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdatePaymentStatusResponse create() =>
      UpdatePaymentStatusResponse._();
  @$core.override
  UpdatePaymentStatusResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdatePaymentStatusResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdatePaymentStatusResponse>(create);
  static UpdatePaymentStatusResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Order get order => $_getN(0);
  @$pb.TagNumber(1)
  set order(Order value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasOrder() => $_has(0);
  @$pb.TagNumber(1)
  void clearOrder() => $_clearField(1);
  @$pb.TagNumber(1)
  Order ensureOrder() => $_ensure(0);
}

/// CommerceService handles marketplace listings and order management.
class CommerceServiceApi {
  final $pb.RpcClient _client;

  CommerceServiceApi(this._client);

  /// Listings
  $async.Future<CreateListingResponse> createListing(
          $pb.ClientContext? ctx, CreateListingRequest request) =>
      _client.invoke<CreateListingResponse>(ctx, 'CommerceService',
          'CreateListing', request, CreateListingResponse());
  $async.Future<GetListingResponse> getListing(
          $pb.ClientContext? ctx, GetListingRequest request) =>
      _client.invoke<GetListingResponse>(
          ctx, 'CommerceService', 'GetListing', request, GetListingResponse());
  $async.Future<ListListingsResponse> listListings(
          $pb.ClientContext? ctx, ListListingsRequest request) =>
      _client.invoke<ListListingsResponse>(ctx, 'CommerceService',
          'ListListings', request, ListListingsResponse());
  $async.Future<UpdateListingResponse> updateListing(
          $pb.ClientContext? ctx, UpdateListingRequest request) =>
      _client.invoke<UpdateListingResponse>(ctx, 'CommerceService',
          'UpdateListing', request, UpdateListingResponse());
  $async.Future<ActivateListingResponse> activateListing(
          $pb.ClientContext? ctx, ActivateListingRequest request) =>
      _client.invoke<ActivateListingResponse>(ctx, 'CommerceService',
          'ActivateListing', request, ActivateListingResponse());
  $async.Future<CancelListingResponse> cancelListing(
          $pb.ClientContext? ctx, CancelListingRequest request) =>
      _client.invoke<CancelListingResponse>(ctx, 'CommerceService',
          'CancelListing', request, CancelListingResponse());

  /// Orders
  $async.Future<PlaceOrderResponse> placeOrder(
          $pb.ClientContext? ctx, PlaceOrderRequest request) =>
      _client.invoke<PlaceOrderResponse>(
          ctx, 'CommerceService', 'PlaceOrder', request, PlaceOrderResponse());
  $async.Future<GetOrderResponse> getOrder(
          $pb.ClientContext? ctx, GetOrderRequest request) =>
      _client.invoke<GetOrderResponse>(
          ctx, 'CommerceService', 'GetOrder', request, GetOrderResponse());
  $async.Future<ListOrdersResponse> listOrders(
          $pb.ClientContext? ctx, ListOrdersRequest request) =>
      _client.invoke<ListOrdersResponse>(
          ctx, 'CommerceService', 'ListOrders', request, ListOrdersResponse());
  $async.Future<UpdateOrderStatusResponse> updateOrderStatus(
          $pb.ClientContext? ctx, UpdateOrderStatusRequest request) =>
      _client.invoke<UpdateOrderStatusResponse>(ctx, 'CommerceService',
          'UpdateOrderStatus', request, UpdateOrderStatusResponse());
  $async.Future<UpdatePaymentStatusResponse> updatePaymentStatus(
          $pb.ClientContext? ctx, UpdatePaymentStatusRequest request) =>
      _client.invoke<UpdatePaymentStatusResponse>(ctx, 'CommerceService',
          'UpdatePaymentStatus', request, UpdatePaymentStatusResponse());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
