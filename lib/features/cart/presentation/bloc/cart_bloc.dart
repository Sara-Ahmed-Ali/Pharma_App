import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/failures.dart';
import '../../domain/entities/cart.dart';
import '../../domain/repositories/cart_repository.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository _cartRepository;

  CartBloc(this._cartRepository) : super(CartInitial()) {
    on<CartFetchRequested>(_onFetch);
    on<CartItemAdded>(_onAdd);
    on<CartItemQuantityUpdated>(_onUpdateQuantity);
    on<CartItemRemoved>(_onRemove);
    on<CartCleared>(_onClear);
  }

  Future<void> _onFetch(CartFetchRequested event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final cart = await _cartRepository.getCart();
      emit(CartLoaded(cart));
    } catch (e) {
      emit(CartError(_messageOf(e)));
    }
  }

  Future<void> _onAdd(CartItemAdded event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final cart = await _cartRepository.addToCart(
        productId: event.productId,
        quantity: event.quantity,
      );
      emit(CartLoaded(cart));
    } catch (e) {
      emit(CartError(_messageOf(e)));
    }
  }

  Future<void> _onUpdateQuantity(
    CartItemQuantityUpdated event,
    Emitter<CartState> emit,
  ) async {
    if (event.quantity <= 0) {
      return _remove(event.productId, emit);
    }

    // Optimistically update the local quantity for a snappy UI.
    final current = state;
    if (current is CartLoaded) {
      final updatedItems = current.cart.items
          .map((item) => item.productId == event.productId
              ? item.copyWith(quantity: event.quantity)
              : item)
          .toList();
      emit(CartLoaded(Cart(
        userId: current.cart.userId,
        items: updatedItems,
        totalPrice: _totalOf(updatedItems),
      )));
    }

    try {
      final cart = await _cartRepository.updateQuantity(
        productId: event.productId,
        quantity: event.quantity,
      );
      emit(CartLoaded(cart));
    } catch (e) {
      // Revert to the persisted cart on failure.
      try {
        final cart = await _cartRepository.getCart();
        emit(CartLoaded(cart));
      } catch (_) {
        emit(CartError(_messageOf(e)));
      }
    }
  }

  Future<void> _onRemove(
    CartItemRemoved event,
    Emitter<CartState> emit,
  ) async {
    final current = state;
    if (current is CartLoaded) {
      emit(CartLoaded(Cart(
        userId: current.cart.userId,
        items: current.cart.items
            .where((item) => item.productId != event.productId)
            .toList(),
        totalPrice: current.cart.totalPrice,
      )));
    }
    try {
      final cart = await _cartRepository.removeFromCart(event.productId);
      emit(CartLoaded(cart));
    } catch (e) {
      emit(CartError(_messageOf(e)));
    }
  }

  Future<void> _onClear(CartCleared event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      await _cartRepository.clearCart();
      emit(const CartLoaded(Cart(userId: 0, items: [], totalPrice: 0)));
    } catch (e) {
      emit(CartError(_messageOf(e)));
    }
  }

  Future<void> _remove(int productId, Emitter<CartState> emit) async {
    final current = state;
    if (current is CartLoaded) {
      emit(CartLoaded(Cart(
        userId: current.cart.userId,
        items: current.cart.items
            .where((item) => item.productId != productId)
            .toList(),
        totalPrice: current.cart.totalPrice,
      )));
    }
    try {
      final cart = await _cartRepository.removeFromCart(productId);
      emit(CartLoaded(cart));
    } catch (e) {
      emit(CartError(_messageOf(e)));
    }
  }

  double _totalOf(List<CartItem> items) =>
      items.fold(0, (sum, item) => sum + item.subTotal);

  String _messageOf(Object error) {
    if (error is Failure) return error.message;
    if (error is AppException) return error.message;
    return 'An unexpected error occurred.';
  }
}