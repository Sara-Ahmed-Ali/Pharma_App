import 'package:dio/dio.dart';

import '../../domain/entities/payment_intent.dart';
import '../../domain/repositories/payment_repository.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final Dio _dio;

  PaymentRepositoryImpl(this._dio);

  @override
  Future<PaymentIntent> createPaymentIntent({
    required int orderId,
    required String currency,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/Payments/create-intent',
      data: {
        'orderId': orderId,
        'currency': currency.toLowerCase(),
      },
    );

    final data = response.data;
    if (data == null) {
      throw const FormatException('Invalid payment response');
    }

    return PaymentIntent(
      id: data['paymentIntentId'] as String? ?? '',
      clientSecret: data['clientSecret'] as String? ?? '',
      status: data['status'] as String? ?? '',
      orderId: orderId,
    );
  }
}