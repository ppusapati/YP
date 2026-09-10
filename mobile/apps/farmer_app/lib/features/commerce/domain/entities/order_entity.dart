import 'package:equatable/equatable.dart';

/// Status of an order.
enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  completed,
  cancelled,
  disputed;

  String get label => switch (this) {
        pending => 'Pending',
        confirmed => 'Confirmed',
        processing => 'Processing',
        shipped => 'Shipped',
        delivered => 'Delivered',
        completed => 'Completed',
        cancelled => 'Cancelled',
        disputed => 'Disputed',
      };

  /// Map proto enum int value to [OrderStatus].
  static OrderStatus fromProtoValue(int value) => switch (value) {
        1 => pending,
        2 => confirmed,
        3 => processing,
        4 => shipped,
        5 => delivered,
        6 => completed,
        7 => cancelled,
        8 => disputed,
        _ => pending,
      };

  /// Proto enum int value.
  int get protoValue => switch (this) {
        pending => 1,
        confirmed => 2,
        processing => 3,
        shipped => 4,
        delivered => 5,
        completed => 6,
        cancelled => 7,
        disputed => 8,
      };
}

/// Payment status for an order.
enum PaymentStatus {
  pending,
  paid,
  refunded;

  String get label => switch (this) {
        pending => 'Pending',
        paid => 'Paid',
        refunded => 'Refunded',
      };

  static PaymentStatus fromProtoValue(int value) => switch (value) {
        1 => pending,
        2 => paid,
        3 => refunded,
        _ => pending,
      };
}

/// A purchase order for a marketplace listing.
class Order extends Equatable {
  const Order({
    required this.id,
    required this.listingId,
    required this.buyerId,
    required this.sellerId,
    required this.quantity,
    required this.quantityUnit,
    required this.unitPricePaise,
    required this.totalAmountPaise,
    required this.currency,
    required this.status,
    required this.paymentStatus,
    this.deliveryMethod,
    this.deliveryAddress,
    this.deliveryNotes,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String listingId;
  final String buyerId;
  final String sellerId;
  final double quantity;
  final String quantityUnit;
  final int unitPricePaise;
  final int totalAmountPaise;
  final String currency;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final String? deliveryMethod;
  final String? deliveryAddress;
  final String? deliveryNotes;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Total amount formatted as rupees.
  String get formattedTotal {
    final rupees = totalAmountPaise / 100;
    if (currency == 'INR') {
      return '₹${rupees.toStringAsFixed(2)}';
    }
    return '${rupees.toStringAsFixed(2)} $currency';
  }

  @override
  List<Object?> get props => [
        id,
        listingId,
        buyerId,
        sellerId,
        quantity,
        quantityUnit,
        unitPricePaise,
        totalAmountPaise,
        currency,
        status,
        paymentStatus,
        deliveryMethod,
        deliveryAddress,
        deliveryNotes,
        notes,
        createdAt,
        updatedAt,
      ];
}
