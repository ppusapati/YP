import 'package:equatable/equatable.dart';

import '../../domain/entities/listing_entity.dart';
import '../../domain/entities/order_entity.dart';

/// States for the commerce BLoC.
sealed class CommerceState extends Equatable {
  const CommerceState();

  @override
  List<Object?> get props => [];
}

/// Initial idle state.
class CommerceInitial extends CommerceState {
  const CommerceInitial();
}

/// Data is being fetched.
class CommerceLoading extends CommerceState {
  const CommerceLoading();
}

/// Marketplace listings loaded successfully.
class ListingsLoaded extends CommerceState {
  const ListingsLoaded(this.listings);

  final List<Listing> listings;

  @override
  List<Object?> get props => [listings];
}

/// A single listing loaded.
class ListingDetailLoaded extends CommerceState {
  const ListingDetailLoaded(this.listing);

  final Listing listing;

  @override
  List<Object?> get props => [listing];
}

/// A new listing was created.
class ListingCreated extends CommerceState {
  const ListingCreated(this.listing);

  final Listing listing;

  @override
  List<Object?> get props => [listing];
}

/// An order was placed successfully.
class OrderPlaced extends CommerceState {
  const OrderPlaced(this.order);

  final Order order;

  @override
  List<Object?> get props => [order];
}

/// Orders loaded.
class OrdersLoaded extends CommerceState {
  const OrdersLoaded(this.orders);

  final List<Order> orders;

  @override
  List<Object?> get props => [orders];
}

/// Something went wrong.
class CommerceError extends CommerceState {
  const CommerceError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
