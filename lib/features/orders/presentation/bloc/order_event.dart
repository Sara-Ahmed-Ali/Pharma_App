import 'package:equatable/equatable.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class OrdersFetchRequested extends OrderEvent {
  const OrdersFetchRequested();
}

class OrderSubmitRequested extends OrderEvent {
  final String shippingAddress;
  final String paymentMethod;

  const OrderSubmitRequested({
    required this.shippingAddress,
    required this.paymentMethod,
  });

  @override
  List<Object?> get props => [shippingAddress, paymentMethod];
}

class OrderCancelled extends OrderEvent {
  final int orderId;

  const OrderCancelled(this.orderId);

  @override
  List<Object?> get props => [orderId];
}