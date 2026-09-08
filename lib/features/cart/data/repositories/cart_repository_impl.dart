import 'package:dio/dio.dart';

import '../../domain/entities/cart.dart';
import '../../domain/repositories/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  final Dio _dio;

  CartRepositoryImpl(this._dio);

  @override
  Future<Cart> getCart() async {
    final response = await _dio.get<Map<String, dynamic>>('/Cart');
    return _parseCart(response.data);
  }

  @override
  Future<Cart> addToCart({
    required int productId,
    int quantity = 1,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/Cart/add',
      data: {'productId': productId, 'quantity': quantity},
    );
    return _parseCart(response.data);
  }

  @override
  Future<Cart> updateQuantity({
    required int productId,
    required int quantity,
  }) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/Cart/update',
      data: {'productId': productId, 'quantity': quantity},
    );
    return _parseCart(response.data);
  }

  @override
  Future<Cart> removeFromCart(int productId) async {
    final response =
        await _dio.delete<Map<String, dynamic>>('/Cart/remove/$productId');
    return _parseCart(response.data);
  }

  @override
  Future<void> clearCart() async {
    await _dio.delete('/Cart/clear');
  }

  Cart _parseCart(Map<String, dynamic>? data) {
    if (data == null) {
      return const Cart(userId: 0, items: [], totalPrice: 0);
    }

    final rawItems = data['items'] as List<dynamic>? ?? [];
    final total = (data['totalPrice'] as num?)?.toDouble() ?? 0;

    final items = rawItems
        .whereType<Map<String, dynamic>>()
        .map((json) => _parseItem(json))
        .toList();

    return Cart(
      userId: (data['userId'] as num?)?.toInt() ?? 0,
      items: items,
      totalPrice: total,
    );
  }

  CartItem _parseItem(Map<String, dynamic> json) {
    final unitPrice = (json['unitPrice'] as num?)?.toDouble() ?? 0;
    final quantity = (json['quantity'] as num?)?.toInt() ?? 0;

    return CartItem(
      cartItemId: (json['cartItemId'] as num?)?.toInt() ?? 0,
      productId: (json['productId'] as num?)?.toInt() ?? 0,
      productName: json['productName'] as String? ?? '',
      unitPrice: unitPrice,
      quantity: quantity,
      subTotal: (json['subTotal'] as num?)?.toDouble() ?? (unitPrice * quantity),
      addedAt: _tryParseDate(json['addedAt']),
    );
  }

  DateTime? _tryParseDate(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value as String);
    } catch (_) {
      return null;
    }
  }
}