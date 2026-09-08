import 'package:equatable/equatable.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class CartFetchRequested extends CartEvent {
  const CartFetchRequested();
}

class CartItemAdded extends CartEvent {
  final int productId;
  final int quantity;

  const CartItemAdded({required this.productId, this.quantity = 1});

  @override
  List<Object?> get props => [productId, quantity];
}

class CartItemQuantityUpdated extends CartEvent {
  final int productId;
  final int quantity;

  const CartItemQuantityUpdated({
    required this.productId,
    required this.quantity,
  });

  @override
  List<Object?> get props => [productId, quantity];
}

class CartItemRemoved extends CartEvent {
  final int productId;

  const CartItemRemoved(this.productId);

  @override
  List<Object?> get props => [productId];
}

class CartCleared extends CartEvent {
  const CartCleared();
}