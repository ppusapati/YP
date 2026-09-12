import '../../domain/entities/order_entity.dart';

/// Data transfer model for [Order].
class OrderModel extends Order {
  const OrderModel({
    required super.id,
    required super.listingId,
    required super.buyerId,
    required super.sellerId,
    required super.quantity,
    required super.quantityUnit,
    required super.unitPricePaise,
    required super.totalAmountPaise,
    required super.currency,
    required super.status,
    required super.paymentStatus,
    super.deliveryMethod,
    super.deliveryAddress,
    super.deliveryNotes,
    super.notes,
    super.createdAt,
    super.updatedAt,
  });

  /// Deserialise from ConnectRPC JSON response map.
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String? ?? '',
      listingId: json['listingId'] as String? ?? '',
      buyerId: json['buyerId'] as String? ?? '',
      sellerId: json['sellerId'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      quantityUnit: json['quantityUnit'] as String? ?? 'kg',
      unitPricePaise: _parseInt(json['unitPricePaise']),
      totalAmountPaise: _parseInt(json['totalAmountPaise']),
      currency: json['currency'] as String? ?? 'INR',
      status: OrderStatus.fromProtoValue(_parseStatusInt(json['status'])),
      paymentStatus: PaymentStatus.fromProtoValue(
        _parsePaymentStatusInt(json['paymentStatus']),
      ),
      deliveryMethod: json['deliveryMethod'] as String?,
      deliveryAddress: json['deliveryAddress'] as String?,
      deliveryNotes: json['deliveryNotes'] as String?,
      notes: json['notes'] as String?,
      createdAt: _parseTimestamp(json['createdAt']),
      updatedAt: _parseTimestamp(json['updatedAt']),
    );
  }

  factory OrderModel.fromEntity(Order entity) {
    return OrderModel(
      id: entity.id,
      listingId: entity.listingId,
      buyerId: entity.buyerId,
      sellerId: entity.sellerId,
      quantity: entity.quantity,
      quantityUnit: entity.quantityUnit,
      unitPricePaise: entity.unitPricePaise,
      totalAmountPaise: entity.totalAmountPaise,
      currency: entity.currency,
      status: entity.status,
      paymentStatus: entity.paymentStatus,
      deliveryMethod: entity.deliveryMethod,
      deliveryAddress: entity.deliveryAddress,
      deliveryNotes: entity.deliveryNotes,
      notes: entity.notes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'listingId': listingId,
        'buyerId': buyerId,
        'sellerId': sellerId,
        'quantity': quantity,
        'quantityUnit': quantityUnit,
        'unitPricePaise': unitPricePaise.toString(),
        'totalAmountPaise': totalAmountPaise.toString(),
        'currency': currency,
        'status': status.protoValue,
        'paymentStatus': paymentStatus.protoValue,
        if (deliveryMethod != null) 'deliveryMethod': deliveryMethod,
        if (deliveryAddress != null) 'deliveryAddress': deliveryAddress,
        if (deliveryNotes != null) 'deliveryNotes': deliveryNotes,
        if (notes != null) 'notes': notes,
      };

  // ---------------------------------------------------------------------------
  // Parsing helpers
  // ---------------------------------------------------------------------------

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static int _parseStatusInt(dynamic value) {
    if (value is int) return value;
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
      return switch (value) {
        'ORDER_STATUS_PENDING' => 1,
        'ORDER_STATUS_CONFIRMED' => 2,
        'ORDER_STATUS_PROCESSING' => 3,
        'ORDER_STATUS_SHIPPED' => 4,
        'ORDER_STATUS_DELIVERED' => 5,
        'ORDER_STATUS_COMPLETED' => 6,
        'ORDER_STATUS_CANCELLED' => 7,
        'ORDER_STATUS_DISPUTED' => 8,
        _ => 0,
      };
    }
    return 0;
  }

  static int _parsePaymentStatusInt(dynamic value) {
    if (value is int) return value;
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
      return switch (value) {
        'PAYMENT_STATUS_PENDING' => 1,
        'PAYMENT_STATUS_PAID' => 2,
        'PAYMENT_STATUS_REFUNDED' => 3,
        _ => 0,
      };
    }
    return 0;
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.tryParse(value);
    if (value is Map) {
      final seconds = (value['seconds'] as num?)?.toInt() ?? 0;
      final nanos = (value['nanos'] as num?)?.toInt() ?? 0;
      return DateTime.fromMillisecondsSinceEpoch(
        seconds * 1000 + nanos ~/ 1000000,
      );
    }
    return null;
  }
}
