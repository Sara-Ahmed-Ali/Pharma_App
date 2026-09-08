import '../entities/order.dart';

abstract class OrderRepository {
  Future<Order> submitOrder({
    required String shippingAddress,
    required String paymentMethod,
  });

  Future<List<Order>> getOrders();

  Future<Order> getOrderById(int id);

  Future<void> cancelOrder(int id);
}