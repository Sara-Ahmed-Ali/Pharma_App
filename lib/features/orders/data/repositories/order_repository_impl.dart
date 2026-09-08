import 'package:dio/dio.dart';

import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final Dio _dio;

  OrderRepositoryImpl(this._dio);

  @override
  Future<Order> submitOrder({
    required String shippingAddress,
    required String paymentMethod,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/Orders/submit',
      data: {
        'shippingAddress': shippingAddress.trim(),
        'paymentMethod': paymentMethod,
      },
    );
    return _parseOrder(response.data);
  }

  @override
  Future<List<Order>> getOrders() async {
    final response = await _dio.get<List<dynamic>>('/Orders');
    return (response.data ?? [])
        .whereType<Map<String, dynamic>>()
        .map(_parseOrder)
        .toList();
  }

  @override
  Future<Order> getOrderById(int id) async {
    final response = await _dio.get<Map<String, dynamic>>('/Orders/$id');
    return _parseOrder(response.data);
  }

  @override
  Future<void> cancelOrder(int id) async {
    await _dio.put('/Orders/$id/cancel');
  }

  Order _parseOrder(Map<String, dynamic>? data) {
    if (data == null) {
      throw const FormatException('Invalid order response');
    }

    final rawItems = data['items'] as List<dynamic>? ?? [];

    return Order(
      id: (data['orderId'] as num?)?.toInt() ?? 0,
      orderDate: DateTime.tryParse(data['orderDate'] as String? ?? '') ??
          DateTime.now(),
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0,
      status: data['status'] as String? ?? 'Pending',
      shippingAddress: data['shippingAddress'] as String? ?? '',
      paymentMethod: data['paymentMethod'] as String? ?? 'Cash',
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map((json) => OrderItem(
                productId: (json['productId'] as num?)?.toInt() ?? 0,
                productName: json['productName'] as String? ?? '',
                unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
                quantity: (json['quantity'] as num?)?.toInt() ?? 0,
                totalPrice:
                    (json['totalPrice'] as num?)?.toDouble() ?? 0,
              ))
          .toList(),
    );
  }
}