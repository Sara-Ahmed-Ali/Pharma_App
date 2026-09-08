import '../../domain/entities/cart.dart';

abstract class CartRepository {
  Future<Cart> getCart();

  Future<Cart> addToCart({required int productId, int quantity = 1});

  Future<Cart> updateQuantity({
    required int productId,
    required int quantity,
  });

  Future<Cart> removeFromCart(int productId);

  Future<void> clearCart();
}