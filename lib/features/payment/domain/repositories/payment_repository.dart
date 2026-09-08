import '../../domain/entities/payment_intent.dart';

abstract class PaymentRepository {
  Future<PaymentIntent> createPaymentIntent({
    required int orderId,
    required String currency,
  });
}