import 'package:bloc/bloc.dart';
import 'package:logging/logging.dart';

import '../../domain/repositories/commerce_repository.dart';
import 'commerce_event.dart';
import 'commerce_state.dart';

/// BLoC managing marketplace listings and orders.
class CommerceBloc extends Bloc<CommerceEvent, CommerceState> {
  CommerceBloc({
    required CommerceRepository repository,
  })  : _repository = repository,
        super(const CommerceInitial()) {
    on<LoadListings>(_onLoadListings);
    on<LoadListingDetail>(_onLoadListingDetail);
    on<CreateListing>(_onCreateListing);
    on<PlaceOrder>(_onPlaceOrder);
    on<LoadOrders>(_onLoadOrders);
  }

  final CommerceRepository _repository;
  static final _log = Logger('CommerceBloc');

  Future<void> _onLoadListings(
    LoadListings event,
    Emitter<CommerceState> emit,
  ) async {
    emit(const CommerceLoading());
    try {
      final listings = await _repository.listListings(
        search: event.search,
        region: event.region,
        productType: event.productType,
      );
      emit(ListingsLoaded(listings));
    } catch (e, stack) {
      _log.severe('Failed to load listings', e, stack);
      emit(const CommerceError(
        'Unable to load marketplace listings. Please try again.',
      ));
    }
  }

  Future<void> _onLoadListingDetail(
    LoadListingDetail event,
    Emitter<CommerceState> emit,
  ) async {
    emit(const CommerceLoading());
    try {
      final listing = await _repository.getListing(event.listingId);
      emit(ListingDetailLoaded(listing));
    } catch (e, stack) {
      _log.severe('Failed to load listing detail', e, stack);
      emit(const CommerceError(
        'Unable to load listing details. Please try again.',
      ));
    }
  }

  Future<void> _onCreateListing(
    CreateListing event,
    Emitter<CommerceState> emit,
  ) async {
    emit(const CommerceLoading());
    try {
      final listing = await _repository.createListing(
        farmId: event.farmId,
        productName: event.productName,
        productType: event.productType,
        description: event.description,
        quantityAvailable: event.quantityAvailable,
        quantityUnit: event.quantityUnit,
        pricePerUnitPaise: event.pricePerUnitPaise,
        currency: event.currency,
        cropId: event.cropId,
        minOrderQuantity: event.minOrderQuantity,
        qualityGrade: event.qualityGrade,
        location: event.location,
        region: event.region,
      );
      emit(ListingCreated(listing));
    } catch (e, stack) {
      _log.severe('Failed to create listing', e, stack);
      emit(const CommerceError(
        'Unable to create listing. Please try again.',
      ));
    }
  }

  Future<void> _onPlaceOrder(
    PlaceOrder event,
    Emitter<CommerceState> emit,
  ) async {
    emit(const CommerceLoading());
    try {
      final order = await _repository.placeOrder(
        listingId: event.listingId,
        quantity: event.quantity,
        deliveryAddress: event.deliveryAddress,
        notes: event.notes,
      );
      emit(OrderPlaced(order));
    } catch (e, stack) {
      _log.severe('Failed to place order', e, stack);
      emit(const CommerceError(
        'Unable to place order. Please try again.',
      ));
    }
  }

  Future<void> _onLoadOrders(
    LoadOrders event,
    Emitter<CommerceState> emit,
  ) async {
    emit(const CommerceLoading());
    try {
      final orders = await _repository.listOrders(
        buyerId: event.buyerId,
        sellerId: event.sellerId,
        status: event.status,
      );
      emit(OrdersLoaded(orders));
    } catch (e, stack) {
      _log.severe('Failed to load orders', e, stack);
      emit(const CommerceError(
        'Unable to load orders. Please try again.',
      ));
    }
  }
}
