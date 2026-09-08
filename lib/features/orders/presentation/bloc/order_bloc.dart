import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/failures.dart';
import '../../domain/repositories/order_repository.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository _orderRepository;

  OrderBloc(this._orderRepository) : super(OrderInitial()) {
    on<OrdersFetchRequested>(_onFetchOrders);
    on<OrderSubmitRequested>(_onSubmitOrder);
    on<OrderCancelled>(_onCancelOrder);
  }

  Future<void> _onFetchOrders(
    OrdersFetchRequested event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrdersLoading());
    try {
      final orders = await _orderRepository.getOrders();
      if (orders.isEmpty) {
        emit(OrdersEmpty());
      } else {
        emit(OrdersLoaded(orders));
      }
    } catch (e) {
      emit(OrderError(_messageOf(e)));
    }
  }

  Future<void> _onSubmitOrder(
    OrderSubmitRequested event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderSubmitting());
    try {
      final order = await _orderRepository.submitOrder(
        shippingAddress: event.shippingAddress,
        paymentMethod: event.paymentMethod,
      );
      emit(OrderSubmitted(order));
    } catch (e) {
      emit(OrderError(_messageOf(e)));
    }
  }

  Future<void> _onCancelOrder(
    OrderCancelled event,
    Emitter<OrderState> emit,
  ) async {
    final current = state;
    try {
      await _orderRepository.cancelOrder(event.orderId);
      if (current is OrdersLoaded) {
        emit(OrdersLoading());
        final orders = await _orderRepository.getOrders();
        emit(orders.isEmpty ? OrdersEmpty() : OrdersLoaded(orders));
      }
    } catch (e) {
      emit(OrderError(_messageOf(e)));
    }
  }

  String _messageOf(Object error) {
    if (error is Failure) return error.message;
    if (error is AppException) return error.message;
    return 'An unexpected error occurred.';
  }
}