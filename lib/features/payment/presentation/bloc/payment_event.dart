import 'package:equatable/equatable.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

class CreatePaymentIntent extends PaymentEvent {
  final int orderId;
  final String currency;

  const CreatePaymentIntent({
    required this.orderId,
    this.currency = 'egp',
  });

  @override
  List<Object?> get props => [orderId, currency];
}

class ResetPaymentStatus extends PaymentEvent {
  const ResetPaymentStatus();
}