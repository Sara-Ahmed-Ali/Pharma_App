class CartItem {
  final int cartItemId;
  final int productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final double subTotal;
  final DateTime? addedAt;

  const CartItem({
    required this.cartItemId,
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.subTotal,
    this.addedAt,
  });

  CartItem copyWith({int? quantity}) {
    return CartItem(
      cartItemId: cartItemId,
      productId: productId,
      productName: productName,
      unitPrice: unitPrice,
      quantity: quantity ?? this.quantity,
      subTotal: (quantity ?? this.quantity) * unitPrice,
      addedAt: addedAt,
    );
  }
}

class Cart {
  final int userId;
  final List<CartItem> items;
  final double totalPrice;

  const Cart({
    required this.userId,
    required this.items,
    required this.totalPrice,
  });

  bool get isEmpty => items.isEmpty;

  int get totalItems =>
      items.fold(0, (sum, item) => sum + item.quantity);
}