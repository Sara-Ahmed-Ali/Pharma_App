class OrderItem {
  final int productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final double totalPrice;

  const OrderItem({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.totalPrice,
  });
}

class Order {
  final int id;
  final DateTime orderDate;
  final double totalAmount;
  final String status;
  final String shippingAddress;
  final String paymentMethod;
  final List<OrderItem> items;

  const Order({
    required this.id,
    required this.orderDate,
    required this.totalAmount,
    required this.status,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.items,
  });

  bool get isCancelable => status.toLowerCase() == 'pending';

  bool get isPaid => status.toLowerCase() == 'succeeded';
}

class OrderSummary {
  final int id;
  final DateTime orderDate;
  final double totalAmount;
  final String status;
  final int itemsCount;

  const OrderSummary({
    required this.id,
    required this.orderDate,
    required this.totalAmount,
    required this.status,
    required this.itemsCount,
  });
}