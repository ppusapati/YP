// This is a generated file - do not edit.
//
// Generated from commerce.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

import 'package:protobuf/well_known_types/google/protobuf/timestamp.pbjson.dart'
    as $0;

@$core.Deprecated('Use listingStatusDescriptor instead')
const ListingStatus$json = {
  '1': 'ListingStatus',
  '2': [
    {'1': 'LISTING_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'LISTING_STATUS_DRAFT', '2': 1},
    {'1': 'LISTING_STATUS_ACTIVE', '2': 2},
    {'1': 'LISTING_STATUS_SOLD_OUT', '2': 3},
    {'1': 'LISTING_STATUS_EXPIRED', '2': 4},
    {'1': 'LISTING_STATUS_CANCELLED', '2': 5},
  ],
};

/// Descriptor for `ListingStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List listingStatusDescriptor = $convert.base64Decode(
    'Cg1MaXN0aW5nU3RhdHVzEh4KGkxJU1RJTkdfU1RBVFVTX1VOU1BFQ0lGSUVEEAASGAoUTElTVE'
    'lOR19TVEFUVVNfRFJBRlQQARIZChVMSVNUSU5HX1NUQVRVU19BQ1RJVkUQAhIbChdMSVNUSU5H'
    'X1NUQVRVU19TT0xEX09VVBADEhoKFkxJU1RJTkdfU1RBVFVTX0VYUElSRUQQBBIcChhMSVNUSU'
    '5HX1NUQVRVU19DQU5DRUxMRUQQBQ==');

@$core.Deprecated('Use orderStatusDescriptor instead')
const OrderStatus$json = {
  '1': 'OrderStatus',
  '2': [
    {'1': 'ORDER_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'ORDER_STATUS_PENDING', '2': 1},
    {'1': 'ORDER_STATUS_CONFIRMED', '2': 2},
    {'1': 'ORDER_STATUS_PROCESSING', '2': 3},
    {'1': 'ORDER_STATUS_SHIPPED', '2': 4},
    {'1': 'ORDER_STATUS_DELIVERED', '2': 5},
    {'1': 'ORDER_STATUS_COMPLETED', '2': 6},
    {'1': 'ORDER_STATUS_CANCELLED', '2': 7},
    {'1': 'ORDER_STATUS_DISPUTED', '2': 8},
  ],
};

/// Descriptor for `OrderStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List orderStatusDescriptor = $convert.base64Decode(
    'CgtPcmRlclN0YXR1cxIcChhPUkRFUl9TVEFUVVNfVU5TUEVDSUZJRUQQABIYChRPUkRFUl9TVE'
    'FUVVNfUEVORElORxABEhoKFk9SREVSX1NUQVRVU19DT05GSVJNRUQQAhIbChdPUkRFUl9TVEFU'
    'VVNfUFJPQ0VTU0lORxADEhgKFE9SREVSX1NUQVRVU19TSElQUEVEEAQSGgoWT1JERVJfU1RBVF'
    'VTX0RFTElWRVJFRBAFEhoKFk9SREVSX1NUQVRVU19DT01QTEVURUQQBhIaChZPUkRFUl9TVEFU'
    'VVNfQ0FOQ0VMTEVEEAcSGQoVT1JERVJfU1RBVFVTX0RJU1BVVEVEEAg=');

@$core.Deprecated('Use paymentStatusDescriptor instead')
const PaymentStatus$json = {
  '1': 'PaymentStatus',
  '2': [
    {'1': 'PAYMENT_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'PAYMENT_STATUS_PENDING', '2': 1},
    {'1': 'PAYMENT_STATUS_PAID', '2': 2},
    {'1': 'PAYMENT_STATUS_REFUNDED', '2': 3},
  ],
};

/// Descriptor for `PaymentStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List paymentStatusDescriptor = $convert.base64Decode(
    'Cg1QYXltZW50U3RhdHVzEh4KGlBBWU1FTlRfU1RBVFVTX1VOU1BFQ0lGSUVEEAASGgoWUEFZTU'
    'VOVF9TVEFUVVNfUEVORElORxABEhcKE1BBWU1FTlRfU1RBVFVTX1BBSUQQAhIbChdQQVlNRU5U'
    'X1NUQVRVU19SRUZVTkRFRBAD');

@$core.Deprecated('Use marketplaceListingDescriptor instead')
const MarketplaceListing$json = {
  '1': 'MarketplaceListing',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'farm_id', '3': 3, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'crop_id', '3': 4, '4': 1, '5': 9, '10': 'cropId'},
    {'1': 'product_name', '3': 5, '4': 1, '5': 9, '10': 'productName'},
    {'1': 'product_type', '3': 6, '4': 1, '5': 9, '10': 'productType'},
    {'1': 'description', '3': 7, '4': 1, '5': 9, '10': 'description'},
    {
      '1': 'quantity_available',
      '3': 8,
      '4': 1,
      '5': 1,
      '10': 'quantityAvailable'
    },
    {'1': 'quantity_unit', '3': 9, '4': 1, '5': 9, '10': 'quantityUnit'},
    {
      '1': 'price_per_unit_paise',
      '3': 10,
      '4': 1,
      '5': 3,
      '10': 'pricePerUnitPaise'
    },
    {'1': 'currency', '3': 11, '4': 1, '5': 9, '10': 'currency'},
    {
      '1': 'min_order_quantity',
      '3': 12,
      '4': 1,
      '5': 1,
      '10': 'minOrderQuantity'
    },
    {'1': 'quality_grade', '3': 13, '4': 1, '5': 9, '10': 'qualityGrade'},
    {
      '1': 'traceability_record_id',
      '3': 14,
      '4': 1,
      '5': 9,
      '10': 'traceabilityRecordId'
    },
    {
      '1': 'status',
      '3': 15,
      '4': 1,
      '5': 14,
      '6': '.agriculture.commerce.v1.ListingStatus',
      '10': 'status'
    },
    {'1': 'location', '3': 16, '4': 1, '5': 9, '10': 'location'},
    {'1': 'region', '3': 17, '4': 1, '5': 9, '10': 'region'},
    {'1': 'image_urls', '3': 18, '4': 3, '5': 9, '10': 'imageUrls'},
    {
      '1': 'available_from',
      '3': 19,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'availableFrom'
    },
    {
      '1': 'available_to',
      '3': 20,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'availableTo'
    },
    {'1': 'created_by', '3': 21, '4': 1, '5': 9, '10': 'createdBy'},
    {'1': 'version', '3': 22, '4': 1, '5': 3, '10': 'version'},
    {
      '1': 'created_at',
      '3': 23,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'updated_at',
      '3': 24,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'updatedAt'
    },
    {'1': 'batch_id', '3': 25, '4': 1, '5': 9, '10': 'batchId'},
  ],
};

/// Descriptor for `MarketplaceListing`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List marketplaceListingDescriptor = $convert.base64Decode(
    'ChJNYXJrZXRwbGFjZUxpc3RpbmcSDgoCaWQYASABKAlSAmlkEhsKCXRlbmFudF9pZBgCIAEoCV'
    'IIdGVuYW50SWQSFwoHZmFybV9pZBgDIAEoCVIGZmFybUlkEhcKB2Nyb3BfaWQYBCABKAlSBmNy'
    'b3BJZBIhCgxwcm9kdWN0X25hbWUYBSABKAlSC3Byb2R1Y3ROYW1lEiEKDHByb2R1Y3RfdHlwZR'
    'gGIAEoCVILcHJvZHVjdFR5cGUSIAoLZGVzY3JpcHRpb24YByABKAlSC2Rlc2NyaXB0aW9uEi0K'
    'EnF1YW50aXR5X2F2YWlsYWJsZRgIIAEoAVIRcXVhbnRpdHlBdmFpbGFibGUSIwoNcXVhbnRpdH'
    'lfdW5pdBgJIAEoCVIMcXVhbnRpdHlVbml0Ei8KFHByaWNlX3Blcl91bml0X3BhaXNlGAogASgD'
    'UhFwcmljZVBlclVuaXRQYWlzZRIaCghjdXJyZW5jeRgLIAEoCVIIY3VycmVuY3kSLAoSbWluX2'
    '9yZGVyX3F1YW50aXR5GAwgASgBUhBtaW5PcmRlclF1YW50aXR5EiMKDXF1YWxpdHlfZ3JhZGUY'
    'DSABKAlSDHF1YWxpdHlHcmFkZRI0ChZ0cmFjZWFiaWxpdHlfcmVjb3JkX2lkGA4gASgJUhR0cm'
    'FjZWFiaWxpdHlSZWNvcmRJZBI+CgZzdGF0dXMYDyABKA4yJi5hZ3JpY3VsdHVyZS5jb21tZXJj'
    'ZS52MS5MaXN0aW5nU3RhdHVzUgZzdGF0dXMSGgoIbG9jYXRpb24YECABKAlSCGxvY2F0aW9uEh'
    'YKBnJlZ2lvbhgRIAEoCVIGcmVnaW9uEh0KCmltYWdlX3VybHMYEiADKAlSCWltYWdlVXJscxJB'
    'Cg5hdmFpbGFibGVfZnJvbRgTIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSDWF2YW'
    'lsYWJsZUZyb20SPQoMYXZhaWxhYmxlX3RvGBQgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVz'
    'dGFtcFILYXZhaWxhYmxlVG8SHQoKY3JlYXRlZF9ieRgVIAEoCVIJY3JlYXRlZEJ5EhgKB3Zlcn'
    'Npb24YFiABKANSB3ZlcnNpb24SOQoKY3JlYXRlZF9hdBgXIAEoCzIaLmdvb2dsZS5wcm90b2J1'
    'Zi5UaW1lc3RhbXBSCWNyZWF0ZWRBdBI5Cgp1cGRhdGVkX2F0GBggASgLMhouZ29vZ2xlLnByb3'
    'RvYnVmLlRpbWVzdGFtcFIJdXBkYXRlZEF0EhkKCGJhdGNoX2lkGBkgASgJUgdiYXRjaElk');

@$core.Deprecated('Use orderDescriptor instead')
const Order$json = {
  '1': 'Order',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'listing_id', '3': 3, '4': 1, '5': 9, '10': 'listingId'},
    {'1': 'buyer_id', '3': 4, '4': 1, '5': 9, '10': 'buyerId'},
    {'1': 'seller_id', '3': 5, '4': 1, '5': 9, '10': 'sellerId'},
    {'1': 'quantity', '3': 6, '4': 1, '5': 1, '10': 'quantity'},
    {'1': 'quantity_unit', '3': 7, '4': 1, '5': 9, '10': 'quantityUnit'},
    {'1': 'unit_price_paise', '3': 8, '4': 1, '5': 3, '10': 'unitPricePaise'},
    {
      '1': 'total_amount_paise',
      '3': 9,
      '4': 1,
      '5': 3,
      '10': 'totalAmountPaise'
    },
    {'1': 'currency', '3': 10, '4': 1, '5': 9, '10': 'currency'},
    {
      '1': 'status',
      '3': 11,
      '4': 1,
      '5': 14,
      '6': '.agriculture.commerce.v1.OrderStatus',
      '10': 'status'
    },
    {
      '1': 'payment_status',
      '3': 12,
      '4': 1,
      '5': 14,
      '6': '.agriculture.commerce.v1.PaymentStatus',
      '10': 'paymentStatus'
    },
    {
      '1': 'payment_reference',
      '3': 13,
      '4': 1,
      '5': 9,
      '10': 'paymentReference'
    },
    {'1': 'delivery_method', '3': 14, '4': 1, '5': 9, '10': 'deliveryMethod'},
    {'1': 'delivery_address', '3': 15, '4': 1, '5': 9, '10': 'deliveryAddress'},
    {'1': 'delivery_notes', '3': 16, '4': 1, '5': 9, '10': 'deliveryNotes'},
    {
      '1': 'estimated_delivery_date',
      '3': 17,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'estimatedDeliveryDate'
    },
    {
      '1': 'actual_delivery_date',
      '3': 18,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'actualDeliveryDate'
    },
    {'1': 'notes', '3': 19, '4': 1, '5': 9, '10': 'notes'},
    {'1': 'created_by', '3': 20, '4': 1, '5': 9, '10': 'createdBy'},
    {'1': 'version', '3': 21, '4': 1, '5': 3, '10': 'version'},
    {
      '1': 'created_at',
      '3': 22,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'updated_at',
      '3': 23,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'updatedAt'
    },
  ],
};

/// Descriptor for `Order`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List orderDescriptor = $convert.base64Decode(
    'CgVPcmRlchIOCgJpZBgBIAEoCVICaWQSGwoJdGVuYW50X2lkGAIgASgJUgh0ZW5hbnRJZBIdCg'
    'psaXN0aW5nX2lkGAMgASgJUglsaXN0aW5nSWQSGQoIYnV5ZXJfaWQYBCABKAlSB2J1eWVySWQS'
    'GwoJc2VsbGVyX2lkGAUgASgJUghzZWxsZXJJZBIaCghxdWFudGl0eRgGIAEoAVIIcXVhbnRpdH'
    'kSIwoNcXVhbnRpdHlfdW5pdBgHIAEoCVIMcXVhbnRpdHlVbml0EigKEHVuaXRfcHJpY2VfcGFp'
    'c2UYCCABKANSDnVuaXRQcmljZVBhaXNlEiwKEnRvdGFsX2Ftb3VudF9wYWlzZRgJIAEoA1IQdG'
    '90YWxBbW91bnRQYWlzZRIaCghjdXJyZW5jeRgKIAEoCVIIY3VycmVuY3kSPAoGc3RhdHVzGAsg'
    'ASgOMiQuYWdyaWN1bHR1cmUuY29tbWVyY2UudjEuT3JkZXJTdGF0dXNSBnN0YXR1cxJNCg5wYX'
    'ltZW50X3N0YXR1cxgMIAEoDjImLmFncmljdWx0dXJlLmNvbW1lcmNlLnYxLlBheW1lbnRTdGF0'
    'dXNSDXBheW1lbnRTdGF0dXMSKwoRcGF5bWVudF9yZWZlcmVuY2UYDSABKAlSEHBheW1lbnRSZW'
    'ZlcmVuY2USJwoPZGVsaXZlcnlfbWV0aG9kGA4gASgJUg5kZWxpdmVyeU1ldGhvZBIpChBkZWxp'
    'dmVyeV9hZGRyZXNzGA8gASgJUg9kZWxpdmVyeUFkZHJlc3MSJQoOZGVsaXZlcnlfbm90ZXMYEC'
    'ABKAlSDWRlbGl2ZXJ5Tm90ZXMSUgoXZXN0aW1hdGVkX2RlbGl2ZXJ5X2RhdGUYESABKAsyGi5n'
    'b29nbGUucHJvdG9idWYuVGltZXN0YW1wUhVlc3RpbWF0ZWREZWxpdmVyeURhdGUSTAoUYWN0dW'
    'FsX2RlbGl2ZXJ5X2RhdGUYEiABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUhJhY3R1'
    'YWxEZWxpdmVyeURhdGUSFAoFbm90ZXMYEyABKAlSBW5vdGVzEh0KCmNyZWF0ZWRfYnkYFCABKA'
    'lSCWNyZWF0ZWRCeRIYCgd2ZXJzaW9uGBUgASgDUgd2ZXJzaW9uEjkKCmNyZWF0ZWRfYXQYFiAB'
    'KAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgljcmVhdGVkQXQSOQoKdXBkYXRlZF9hdB'
    'gXIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCXVwZGF0ZWRBdA==');

@$core.Deprecated('Use createListingRequestDescriptor instead')
const CreateListingRequest$json = {
  '1': 'CreateListingRequest',
  '2': [
    {'1': 'farm_id', '3': 1, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'crop_id', '3': 2, '4': 1, '5': 9, '10': 'cropId'},
    {'1': 'product_name', '3': 3, '4': 1, '5': 9, '10': 'productName'},
    {'1': 'product_type', '3': 4, '4': 1, '5': 9, '10': 'productType'},
    {'1': 'description', '3': 5, '4': 1, '5': 9, '10': 'description'},
    {
      '1': 'quantity_available',
      '3': 6,
      '4': 1,
      '5': 1,
      '10': 'quantityAvailable'
    },
    {'1': 'quantity_unit', '3': 7, '4': 1, '5': 9, '10': 'quantityUnit'},
    {
      '1': 'price_per_unit_paise',
      '3': 8,
      '4': 1,
      '5': 3,
      '10': 'pricePerUnitPaise'
    },
    {'1': 'currency', '3': 9, '4': 1, '5': 9, '10': 'currency'},
    {
      '1': 'min_order_quantity',
      '3': 10,
      '4': 1,
      '5': 1,
      '10': 'minOrderQuantity'
    },
    {'1': 'quality_grade', '3': 11, '4': 1, '5': 9, '10': 'qualityGrade'},
    {
      '1': 'traceability_record_id',
      '3': 12,
      '4': 1,
      '5': 9,
      '10': 'traceabilityRecordId'
    },
    {'1': 'location', '3': 13, '4': 1, '5': 9, '10': 'location'},
    {'1': 'region', '3': 14, '4': 1, '5': 9, '10': 'region'},
    {'1': 'image_urls', '3': 15, '4': 3, '5': 9, '10': 'imageUrls'},
    {
      '1': 'available_from',
      '3': 16,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'availableFrom'
    },
    {
      '1': 'available_to',
      '3': 17,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'availableTo'
    },
    {'1': 'batch_id', '3': 18, '4': 1, '5': 9, '10': 'batchId'},
  ],
};

/// Descriptor for `CreateListingRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createListingRequestDescriptor = $convert.base64Decode(
    'ChRDcmVhdGVMaXN0aW5nUmVxdWVzdBIXCgdmYXJtX2lkGAEgASgJUgZmYXJtSWQSFwoHY3JvcF'
    '9pZBgCIAEoCVIGY3JvcElkEiEKDHByb2R1Y3RfbmFtZRgDIAEoCVILcHJvZHVjdE5hbWUSIQoM'
    'cHJvZHVjdF90eXBlGAQgASgJUgtwcm9kdWN0VHlwZRIgCgtkZXNjcmlwdGlvbhgFIAEoCVILZG'
    'VzY3JpcHRpb24SLQoScXVhbnRpdHlfYXZhaWxhYmxlGAYgASgBUhFxdWFudGl0eUF2YWlsYWJs'
    'ZRIjCg1xdWFudGl0eV91bml0GAcgASgJUgxxdWFudGl0eVVuaXQSLwoUcHJpY2VfcGVyX3VuaX'
    'RfcGFpc2UYCCABKANSEXByaWNlUGVyVW5pdFBhaXNlEhoKCGN1cnJlbmN5GAkgASgJUghjdXJy'
    'ZW5jeRIsChJtaW5fb3JkZXJfcXVhbnRpdHkYCiABKAFSEG1pbk9yZGVyUXVhbnRpdHkSIwoNcX'
    'VhbGl0eV9ncmFkZRgLIAEoCVIMcXVhbGl0eUdyYWRlEjQKFnRyYWNlYWJpbGl0eV9yZWNvcmRf'
    'aWQYDCABKAlSFHRyYWNlYWJpbGl0eVJlY29yZElkEhoKCGxvY2F0aW9uGA0gASgJUghsb2NhdG'
    'lvbhIWCgZyZWdpb24YDiABKAlSBnJlZ2lvbhIdCgppbWFnZV91cmxzGA8gAygJUglpbWFnZVVy'
    'bHMSQQoOYXZhaWxhYmxlX2Zyb20YECABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUg'
    '1hdmFpbGFibGVGcm9tEj0KDGF2YWlsYWJsZV90bxgRIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5U'
    'aW1lc3RhbXBSC2F2YWlsYWJsZVRvEhkKCGJhdGNoX2lkGBIgASgJUgdiYXRjaElk');

@$core.Deprecated('Use createListingResponseDescriptor instead')
const CreateListingResponse$json = {
  '1': 'CreateListingResponse',
  '2': [
    {
      '1': 'listing',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.commerce.v1.MarketplaceListing',
      '10': 'listing'
    },
  ],
};

/// Descriptor for `CreateListingResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createListingResponseDescriptor = $convert.base64Decode(
    'ChVDcmVhdGVMaXN0aW5nUmVzcG9uc2USRQoHbGlzdGluZxgBIAEoCzIrLmFncmljdWx0dXJlLm'
    'NvbW1lcmNlLnYxLk1hcmtldHBsYWNlTGlzdGluZ1IHbGlzdGluZw==');

@$core.Deprecated('Use getListingRequestDescriptor instead')
const GetListingRequest$json = {
  '1': 'GetListingRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `GetListingRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getListingRequestDescriptor =
    $convert.base64Decode('ChFHZXRMaXN0aW5nUmVxdWVzdBIOCgJpZBgBIAEoCVICaWQ=');

@$core.Deprecated('Use getListingResponseDescriptor instead')
const GetListingResponse$json = {
  '1': 'GetListingResponse',
  '2': [
    {
      '1': 'listing',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.commerce.v1.MarketplaceListing',
      '10': 'listing'
    },
  ],
};

/// Descriptor for `GetListingResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getListingResponseDescriptor = $convert.base64Decode(
    'ChJHZXRMaXN0aW5nUmVzcG9uc2USRQoHbGlzdGluZxgBIAEoCzIrLmFncmljdWx0dXJlLmNvbW'
    '1lcmNlLnYxLk1hcmtldHBsYWNlTGlzdGluZ1IHbGlzdGluZw==');

@$core.Deprecated('Use listListingsRequestDescriptor instead')
const ListListingsRequest$json = {
  '1': 'ListListingsRequest',
  '2': [
    {'1': 'farm_id', '3': 1, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'crop_id', '3': 2, '4': 1, '5': 9, '10': 'cropId'},
    {'1': 'product_type', '3': 3, '4': 1, '5': 9, '10': 'productType'},
    {'1': 'region', '3': 4, '4': 1, '5': 9, '10': 'region'},
    {
      '1': 'status',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.agriculture.commerce.v1.ListingStatus',
      '10': 'status'
    },
    {'1': 'search', '3': 6, '4': 1, '5': 9, '10': 'search'},
    {'1': 'page_size', '3': 7, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_offset', '3': 8, '4': 1, '5': 5, '10': 'pageOffset'},
  ],
};

/// Descriptor for `ListListingsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listListingsRequestDescriptor = $convert.base64Decode(
    'ChNMaXN0TGlzdGluZ3NSZXF1ZXN0EhcKB2Zhcm1faWQYASABKAlSBmZhcm1JZBIXCgdjcm9wX2'
    'lkGAIgASgJUgZjcm9wSWQSIQoMcHJvZHVjdF90eXBlGAMgASgJUgtwcm9kdWN0VHlwZRIWCgZy'
    'ZWdpb24YBCABKAlSBnJlZ2lvbhI+CgZzdGF0dXMYBSABKA4yJi5hZ3JpY3VsdHVyZS5jb21tZX'
    'JjZS52MS5MaXN0aW5nU3RhdHVzUgZzdGF0dXMSFgoGc2VhcmNoGAYgASgJUgZzZWFyY2gSGwoJ'
    'cGFnZV9zaXplGAcgASgFUghwYWdlU2l6ZRIfCgtwYWdlX29mZnNldBgIIAEoBVIKcGFnZU9mZn'
    'NldA==');

@$core.Deprecated('Use listListingsResponseDescriptor instead')
const ListListingsResponse$json = {
  '1': 'ListListingsResponse',
  '2': [
    {
      '1': 'listings',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.commerce.v1.MarketplaceListing',
      '10': 'listings'
    },
    {'1': 'total_count', '3': 2, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListListingsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listListingsResponseDescriptor = $convert.base64Decode(
    'ChRMaXN0TGlzdGluZ3NSZXNwb25zZRJHCghsaXN0aW5ncxgBIAMoCzIrLmFncmljdWx0dXJlLm'
    'NvbW1lcmNlLnYxLk1hcmtldHBsYWNlTGlzdGluZ1IIbGlzdGluZ3MSHwoLdG90YWxfY291bnQY'
    'AiABKAVSCnRvdGFsQ291bnQ=');

@$core.Deprecated('Use updateListingRequestDescriptor instead')
const UpdateListingRequest$json = {
  '1': 'UpdateListingRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'product_name', '3': 2, '4': 1, '5': 9, '10': 'productName'},
    {'1': 'description', '3': 3, '4': 1, '5': 9, '10': 'description'},
    {
      '1': 'quantity_available',
      '3': 4,
      '4': 1,
      '5': 1,
      '10': 'quantityAvailable'
    },
    {
      '1': 'price_per_unit_paise',
      '3': 5,
      '4': 1,
      '5': 3,
      '10': 'pricePerUnitPaise'
    },
    {
      '1': 'min_order_quantity',
      '3': 6,
      '4': 1,
      '5': 1,
      '10': 'minOrderQuantity'
    },
    {'1': 'quality_grade', '3': 7, '4': 1, '5': 9, '10': 'qualityGrade'},
    {'1': 'image_urls', '3': 8, '4': 3, '5': 9, '10': 'imageUrls'},
    {
      '1': 'available_to',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'availableTo'
    },
  ],
};

/// Descriptor for `UpdateListingRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateListingRequestDescriptor = $convert.base64Decode(
    'ChRVcGRhdGVMaXN0aW5nUmVxdWVzdBIOCgJpZBgBIAEoCVICaWQSIQoMcHJvZHVjdF9uYW1lGA'
    'IgASgJUgtwcm9kdWN0TmFtZRIgCgtkZXNjcmlwdGlvbhgDIAEoCVILZGVzY3JpcHRpb24SLQoS'
    'cXVhbnRpdHlfYXZhaWxhYmxlGAQgASgBUhFxdWFudGl0eUF2YWlsYWJsZRIvChRwcmljZV9wZX'
    'JfdW5pdF9wYWlzZRgFIAEoA1IRcHJpY2VQZXJVbml0UGFpc2USLAoSbWluX29yZGVyX3F1YW50'
    'aXR5GAYgASgBUhBtaW5PcmRlclF1YW50aXR5EiMKDXF1YWxpdHlfZ3JhZGUYByABKAlSDHF1YW'
    'xpdHlHcmFkZRIdCgppbWFnZV91cmxzGAggAygJUglpbWFnZVVybHMSPQoMYXZhaWxhYmxlX3Rv'
    'GAkgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFILYXZhaWxhYmxlVG8=');

@$core.Deprecated('Use updateListingResponseDescriptor instead')
const UpdateListingResponse$json = {
  '1': 'UpdateListingResponse',
  '2': [
    {
      '1': 'listing',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.commerce.v1.MarketplaceListing',
      '10': 'listing'
    },
  ],
};

/// Descriptor for `UpdateListingResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateListingResponseDescriptor = $convert.base64Decode(
    'ChVVcGRhdGVMaXN0aW5nUmVzcG9uc2USRQoHbGlzdGluZxgBIAEoCzIrLmFncmljdWx0dXJlLm'
    'NvbW1lcmNlLnYxLk1hcmtldHBsYWNlTGlzdGluZ1IHbGlzdGluZw==');

@$core.Deprecated('Use activateListingRequestDescriptor instead')
const ActivateListingRequest$json = {
  '1': 'ActivateListingRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `ActivateListingRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List activateListingRequestDescriptor = $convert
    .base64Decode('ChZBY3RpdmF0ZUxpc3RpbmdSZXF1ZXN0Eg4KAmlkGAEgASgJUgJpZA==');

@$core.Deprecated('Use activateListingResponseDescriptor instead')
const ActivateListingResponse$json = {
  '1': 'ActivateListingResponse',
  '2': [
    {
      '1': 'listing',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.commerce.v1.MarketplaceListing',
      '10': 'listing'
    },
  ],
};

/// Descriptor for `ActivateListingResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List activateListingResponseDescriptor =
    $convert.base64Decode(
        'ChdBY3RpdmF0ZUxpc3RpbmdSZXNwb25zZRJFCgdsaXN0aW5nGAEgASgLMisuYWdyaWN1bHR1cm'
        'UuY29tbWVyY2UudjEuTWFya2V0cGxhY2VMaXN0aW5nUgdsaXN0aW5n');

@$core.Deprecated('Use cancelListingRequestDescriptor instead')
const CancelListingRequest$json = {
  '1': 'CancelListingRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `CancelListingRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cancelListingRequestDescriptor = $convert
    .base64Decode('ChRDYW5jZWxMaXN0aW5nUmVxdWVzdBIOCgJpZBgBIAEoCVICaWQ=');

@$core.Deprecated('Use cancelListingResponseDescriptor instead')
const CancelListingResponse$json = {
  '1': 'CancelListingResponse',
  '2': [
    {
      '1': 'listing',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.commerce.v1.MarketplaceListing',
      '10': 'listing'
    },
  ],
};

/// Descriptor for `CancelListingResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cancelListingResponseDescriptor = $convert.base64Decode(
    'ChVDYW5jZWxMaXN0aW5nUmVzcG9uc2USRQoHbGlzdGluZxgBIAEoCzIrLmFncmljdWx0dXJlLm'
    'NvbW1lcmNlLnYxLk1hcmtldHBsYWNlTGlzdGluZ1IHbGlzdGluZw==');

@$core.Deprecated('Use placeOrderRequestDescriptor instead')
const PlaceOrderRequest$json = {
  '1': 'PlaceOrderRequest',
  '2': [
    {'1': 'listing_id', '3': 1, '4': 1, '5': 9, '10': 'listingId'},
    {'1': 'quantity', '3': 2, '4': 1, '5': 1, '10': 'quantity'},
    {'1': 'delivery_method', '3': 3, '4': 1, '5': 9, '10': 'deliveryMethod'},
    {'1': 'delivery_address', '3': 4, '4': 1, '5': 9, '10': 'deliveryAddress'},
    {'1': 'delivery_notes', '3': 5, '4': 1, '5': 9, '10': 'deliveryNotes'},
    {'1': 'notes', '3': 6, '4': 1, '5': 9, '10': 'notes'},
  ],
};

/// Descriptor for `PlaceOrderRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List placeOrderRequestDescriptor = $convert.base64Decode(
    'ChFQbGFjZU9yZGVyUmVxdWVzdBIdCgpsaXN0aW5nX2lkGAEgASgJUglsaXN0aW5nSWQSGgoIcX'
    'VhbnRpdHkYAiABKAFSCHF1YW50aXR5EicKD2RlbGl2ZXJ5X21ldGhvZBgDIAEoCVIOZGVsaXZl'
    'cnlNZXRob2QSKQoQZGVsaXZlcnlfYWRkcmVzcxgEIAEoCVIPZGVsaXZlcnlBZGRyZXNzEiUKDm'
    'RlbGl2ZXJ5X25vdGVzGAUgASgJUg1kZWxpdmVyeU5vdGVzEhQKBW5vdGVzGAYgASgJUgVub3Rl'
    'cw==');

@$core.Deprecated('Use placeOrderResponseDescriptor instead')
const PlaceOrderResponse$json = {
  '1': 'PlaceOrderResponse',
  '2': [
    {
      '1': 'order',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.commerce.v1.Order',
      '10': 'order'
    },
  ],
};

/// Descriptor for `PlaceOrderResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List placeOrderResponseDescriptor = $convert.base64Decode(
    'ChJQbGFjZU9yZGVyUmVzcG9uc2USNAoFb3JkZXIYASABKAsyHi5hZ3JpY3VsdHVyZS5jb21tZX'
    'JjZS52MS5PcmRlclIFb3JkZXI=');

@$core.Deprecated('Use getOrderRequestDescriptor instead')
const GetOrderRequest$json = {
  '1': 'GetOrderRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `GetOrderRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getOrderRequestDescriptor =
    $convert.base64Decode('Cg9HZXRPcmRlclJlcXVlc3QSDgoCaWQYASABKAlSAmlk');

@$core.Deprecated('Use getOrderResponseDescriptor instead')
const GetOrderResponse$json = {
  '1': 'GetOrderResponse',
  '2': [
    {
      '1': 'order',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.commerce.v1.Order',
      '10': 'order'
    },
  ],
};

/// Descriptor for `GetOrderResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getOrderResponseDescriptor = $convert.base64Decode(
    'ChBHZXRPcmRlclJlc3BvbnNlEjQKBW9yZGVyGAEgASgLMh4uYWdyaWN1bHR1cmUuY29tbWVyY2'
    'UudjEuT3JkZXJSBW9yZGVy');

@$core.Deprecated('Use listOrdersRequestDescriptor instead')
const ListOrdersRequest$json = {
  '1': 'ListOrdersRequest',
  '2': [
    {'1': 'listing_id', '3': 1, '4': 1, '5': 9, '10': 'listingId'},
    {'1': 'buyer_id', '3': 2, '4': 1, '5': 9, '10': 'buyerId'},
    {'1': 'seller_id', '3': 3, '4': 1, '5': 9, '10': 'sellerId'},
    {
      '1': 'status',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.agriculture.commerce.v1.OrderStatus',
      '10': 'status'
    },
    {'1': 'page_size', '3': 5, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_offset', '3': 6, '4': 1, '5': 5, '10': 'pageOffset'},
  ],
};

/// Descriptor for `ListOrdersRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listOrdersRequestDescriptor = $convert.base64Decode(
    'ChFMaXN0T3JkZXJzUmVxdWVzdBIdCgpsaXN0aW5nX2lkGAEgASgJUglsaXN0aW5nSWQSGQoIYn'
    'V5ZXJfaWQYAiABKAlSB2J1eWVySWQSGwoJc2VsbGVyX2lkGAMgASgJUghzZWxsZXJJZBI8CgZz'
    'dGF0dXMYBCABKA4yJC5hZ3JpY3VsdHVyZS5jb21tZXJjZS52MS5PcmRlclN0YXR1c1IGc3RhdH'
    'VzEhsKCXBhZ2Vfc2l6ZRgFIAEoBVIIcGFnZVNpemUSHwoLcGFnZV9vZmZzZXQYBiABKAVSCnBh'
    'Z2VPZmZzZXQ=');

@$core.Deprecated('Use listOrdersResponseDescriptor instead')
const ListOrdersResponse$json = {
  '1': 'ListOrdersResponse',
  '2': [
    {
      '1': 'orders',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.commerce.v1.Order',
      '10': 'orders'
    },
    {'1': 'total_count', '3': 2, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListOrdersResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listOrdersResponseDescriptor = $convert.base64Decode(
    'ChJMaXN0T3JkZXJzUmVzcG9uc2USNgoGb3JkZXJzGAEgAygLMh4uYWdyaWN1bHR1cmUuY29tbW'
    'VyY2UudjEuT3JkZXJSBm9yZGVycxIfCgt0b3RhbF9jb3VudBgCIAEoBVIKdG90YWxDb3VudA==');

@$core.Deprecated('Use updateOrderStatusRequestDescriptor instead')
const UpdateOrderStatusRequest$json = {
  '1': 'UpdateOrderStatusRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'status',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.agriculture.commerce.v1.OrderStatus',
      '10': 'status'
    },
    {'1': 'notes', '3': 3, '4': 1, '5': 9, '10': 'notes'},
  ],
};

/// Descriptor for `UpdateOrderStatusRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateOrderStatusRequestDescriptor = $convert.base64Decode(
    'ChhVcGRhdGVPcmRlclN0YXR1c1JlcXVlc3QSDgoCaWQYASABKAlSAmlkEjwKBnN0YXR1cxgCIA'
    'EoDjIkLmFncmljdWx0dXJlLmNvbW1lcmNlLnYxLk9yZGVyU3RhdHVzUgZzdGF0dXMSFAoFbm90'
    'ZXMYAyABKAlSBW5vdGVz');

@$core.Deprecated('Use updateOrderStatusResponseDescriptor instead')
const UpdateOrderStatusResponse$json = {
  '1': 'UpdateOrderStatusResponse',
  '2': [
    {
      '1': 'order',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.commerce.v1.Order',
      '10': 'order'
    },
  ],
};

/// Descriptor for `UpdateOrderStatusResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateOrderStatusResponseDescriptor =
    $convert.base64Decode(
        'ChlVcGRhdGVPcmRlclN0YXR1c1Jlc3BvbnNlEjQKBW9yZGVyGAEgASgLMh4uYWdyaWN1bHR1cm'
        'UuY29tbWVyY2UudjEuT3JkZXJSBW9yZGVy');

@$core.Deprecated('Use updatePaymentStatusRequestDescriptor instead')
const UpdatePaymentStatusRequest$json = {
  '1': 'UpdatePaymentStatusRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'payment_status',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.agriculture.commerce.v1.PaymentStatus',
      '10': 'paymentStatus'
    },
    {
      '1': 'payment_reference',
      '3': 3,
      '4': 1,
      '5': 9,
      '10': 'paymentReference'
    },
  ],
};

/// Descriptor for `UpdatePaymentStatusRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updatePaymentStatusRequestDescriptor = $convert.base64Decode(
    'ChpVcGRhdGVQYXltZW50U3RhdHVzUmVxdWVzdBIOCgJpZBgBIAEoCVICaWQSTQoOcGF5bWVudF'
    '9zdGF0dXMYAiABKA4yJi5hZ3JpY3VsdHVyZS5jb21tZXJjZS52MS5QYXltZW50U3RhdHVzUg1w'
    'YXltZW50U3RhdHVzEisKEXBheW1lbnRfcmVmZXJlbmNlGAMgASgJUhBwYXltZW50UmVmZXJlbm'
    'Nl');

@$core.Deprecated('Use updatePaymentStatusResponseDescriptor instead')
const UpdatePaymentStatusResponse$json = {
  '1': 'UpdatePaymentStatusResponse',
  '2': [
    {
      '1': 'order',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.commerce.v1.Order',
      '10': 'order'
    },
  ],
};

/// Descriptor for `UpdatePaymentStatusResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updatePaymentStatusResponseDescriptor =
    $convert.base64Decode(
        'ChtVcGRhdGVQYXltZW50U3RhdHVzUmVzcG9uc2USNAoFb3JkZXIYASABKAsyHi5hZ3JpY3VsdH'
        'VyZS5jb21tZXJjZS52MS5PcmRlclIFb3JkZXI=');

const $core.Map<$core.String, $core.dynamic> CommerceServiceBase$json = {
  '1': 'CommerceService',
  '2': [
    {
      '1': 'CreateListing',
      '2': '.agriculture.commerce.v1.CreateListingRequest',
      '3': '.agriculture.commerce.v1.CreateListingResponse'
    },
    {
      '1': 'GetListing',
      '2': '.agriculture.commerce.v1.GetListingRequest',
      '3': '.agriculture.commerce.v1.GetListingResponse'
    },
    {
      '1': 'ListListings',
      '2': '.agriculture.commerce.v1.ListListingsRequest',
      '3': '.agriculture.commerce.v1.ListListingsResponse'
    },
    {
      '1': 'UpdateListing',
      '2': '.agriculture.commerce.v1.UpdateListingRequest',
      '3': '.agriculture.commerce.v1.UpdateListingResponse'
    },
    {
      '1': 'ActivateListing',
      '2': '.agriculture.commerce.v1.ActivateListingRequest',
      '3': '.agriculture.commerce.v1.ActivateListingResponse'
    },
    {
      '1': 'CancelListing',
      '2': '.agriculture.commerce.v1.CancelListingRequest',
      '3': '.agriculture.commerce.v1.CancelListingResponse'
    },
    {
      '1': 'PlaceOrder',
      '2': '.agriculture.commerce.v1.PlaceOrderRequest',
      '3': '.agriculture.commerce.v1.PlaceOrderResponse'
    },
    {
      '1': 'GetOrder',
      '2': '.agriculture.commerce.v1.GetOrderRequest',
      '3': '.agriculture.commerce.v1.GetOrderResponse'
    },
    {
      '1': 'ListOrders',
      '2': '.agriculture.commerce.v1.ListOrdersRequest',
      '3': '.agriculture.commerce.v1.ListOrdersResponse'
    },
    {
      '1': 'UpdateOrderStatus',
      '2': '.agriculture.commerce.v1.UpdateOrderStatusRequest',
      '3': '.agriculture.commerce.v1.UpdateOrderStatusResponse'
    },
    {
      '1': 'UpdatePaymentStatus',
      '2': '.agriculture.commerce.v1.UpdatePaymentStatusRequest',
      '3': '.agriculture.commerce.v1.UpdatePaymentStatusResponse'
    },
  ],
};

@$core.Deprecated('Use commerceServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
    CommerceServiceBase$messageJson = {
  '.agriculture.commerce.v1.CreateListingRequest': CreateListingRequest$json,
  '.google.protobuf.Timestamp': $0.Timestamp$json,
  '.agriculture.commerce.v1.CreateListingResponse': CreateListingResponse$json,
  '.agriculture.commerce.v1.MarketplaceListing': MarketplaceListing$json,
  '.agriculture.commerce.v1.GetListingRequest': GetListingRequest$json,
  '.agriculture.commerce.v1.GetListingResponse': GetListingResponse$json,
  '.agriculture.commerce.v1.ListListingsRequest': ListListingsRequest$json,
  '.agriculture.commerce.v1.ListListingsResponse': ListListingsResponse$json,
  '.agriculture.commerce.v1.UpdateListingRequest': UpdateListingRequest$json,
  '.agriculture.commerce.v1.UpdateListingResponse': UpdateListingResponse$json,
  '.agriculture.commerce.v1.ActivateListingRequest':
      ActivateListingRequest$json,
  '.agriculture.commerce.v1.ActivateListingResponse':
      ActivateListingResponse$json,
  '.agriculture.commerce.v1.CancelListingRequest': CancelListingRequest$json,
  '.agriculture.commerce.v1.CancelListingResponse': CancelListingResponse$json,
  '.agriculture.commerce.v1.PlaceOrderRequest': PlaceOrderRequest$json,
  '.agriculture.commerce.v1.PlaceOrderResponse': PlaceOrderResponse$json,
  '.agriculture.commerce.v1.Order': Order$json,
  '.agriculture.commerce.v1.GetOrderRequest': GetOrderRequest$json,
  '.agriculture.commerce.v1.GetOrderResponse': GetOrderResponse$json,
  '.agriculture.commerce.v1.ListOrdersRequest': ListOrdersRequest$json,
  '.agriculture.commerce.v1.ListOrdersResponse': ListOrdersResponse$json,
  '.agriculture.commerce.v1.UpdateOrderStatusRequest':
      UpdateOrderStatusRequest$json,
  '.agriculture.commerce.v1.UpdateOrderStatusResponse':
      UpdateOrderStatusResponse$json,
  '.agriculture.commerce.v1.UpdatePaymentStatusRequest':
      UpdatePaymentStatusRequest$json,
  '.agriculture.commerce.v1.UpdatePaymentStatusResponse':
      UpdatePaymentStatusResponse$json,
};

/// Descriptor for `CommerceService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List commerceServiceDescriptor = $convert.base64Decode(
    'Cg9Db21tZXJjZVNlcnZpY2USbgoNQ3JlYXRlTGlzdGluZxItLmFncmljdWx0dXJlLmNvbW1lcm'
    'NlLnYxLkNyZWF0ZUxpc3RpbmdSZXF1ZXN0Gi4uYWdyaWN1bHR1cmUuY29tbWVyY2UudjEuQ3Jl'
    'YXRlTGlzdGluZ1Jlc3BvbnNlEmUKCkdldExpc3RpbmcSKi5hZ3JpY3VsdHVyZS5jb21tZXJjZS'
    '52MS5HZXRMaXN0aW5nUmVxdWVzdBorLmFncmljdWx0dXJlLmNvbW1lcmNlLnYxLkdldExpc3Rp'
    'bmdSZXNwb25zZRJrCgxMaXN0TGlzdGluZ3MSLC5hZ3JpY3VsdHVyZS5jb21tZXJjZS52MS5MaX'
    'N0TGlzdGluZ3NSZXF1ZXN0Gi0uYWdyaWN1bHR1cmUuY29tbWVyY2UudjEuTGlzdExpc3Rpbmdz'
    'UmVzcG9uc2USbgoNVXBkYXRlTGlzdGluZxItLmFncmljdWx0dXJlLmNvbW1lcmNlLnYxLlVwZG'
    'F0ZUxpc3RpbmdSZXF1ZXN0Gi4uYWdyaWN1bHR1cmUuY29tbWVyY2UudjEuVXBkYXRlTGlzdGlu'
    'Z1Jlc3BvbnNlEnQKD0FjdGl2YXRlTGlzdGluZxIvLmFncmljdWx0dXJlLmNvbW1lcmNlLnYxLk'
    'FjdGl2YXRlTGlzdGluZ1JlcXVlc3QaMC5hZ3JpY3VsdHVyZS5jb21tZXJjZS52MS5BY3RpdmF0'
    'ZUxpc3RpbmdSZXNwb25zZRJuCg1DYW5jZWxMaXN0aW5nEi0uYWdyaWN1bHR1cmUuY29tbWVyY2'
    'UudjEuQ2FuY2VsTGlzdGluZ1JlcXVlc3QaLi5hZ3JpY3VsdHVyZS5jb21tZXJjZS52MS5DYW5j'
    'ZWxMaXN0aW5nUmVzcG9uc2USZQoKUGxhY2VPcmRlchIqLmFncmljdWx0dXJlLmNvbW1lcmNlLn'
    'YxLlBsYWNlT3JkZXJSZXF1ZXN0GisuYWdyaWN1bHR1cmUuY29tbWVyY2UudjEuUGxhY2VPcmRl'
    'clJlc3BvbnNlEl8KCEdldE9yZGVyEiguYWdyaWN1bHR1cmUuY29tbWVyY2UudjEuR2V0T3JkZX'
    'JSZXF1ZXN0GikuYWdyaWN1bHR1cmUuY29tbWVyY2UudjEuR2V0T3JkZXJSZXNwb25zZRJlCgpM'
    'aXN0T3JkZXJzEiouYWdyaWN1bHR1cmUuY29tbWVyY2UudjEuTGlzdE9yZGVyc1JlcXVlc3QaKy'
    '5hZ3JpY3VsdHVyZS5jb21tZXJjZS52MS5MaXN0T3JkZXJzUmVzcG9uc2USegoRVXBkYXRlT3Jk'
    'ZXJTdGF0dXMSMS5hZ3JpY3VsdHVyZS5jb21tZXJjZS52MS5VcGRhdGVPcmRlclN0YXR1c1JlcX'
    'Vlc3QaMi5hZ3JpY3VsdHVyZS5jb21tZXJjZS52MS5VcGRhdGVPcmRlclN0YXR1c1Jlc3BvbnNl'
    'EoABChNVcGRhdGVQYXltZW50U3RhdHVzEjMuYWdyaWN1bHR1cmUuY29tbWVyY2UudjEuVXBkYX'
    'RlUGF5bWVudFN0YXR1c1JlcXVlc3QaNC5hZ3JpY3VsdHVyZS5jb21tZXJjZS52MS5VcGRhdGVQ'
    'YXltZW50U3RhdHVzUmVzcG9uc2U=');
