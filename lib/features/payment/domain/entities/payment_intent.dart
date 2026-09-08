class PaymentIntent {
  final String id;
  final String clientSecret;
  final String status;
  final int orderId;

  const PaymentIntent({
    required this.id,
    required this.clientSecret,
    required this.status,
    required this.orderId,
  });
}