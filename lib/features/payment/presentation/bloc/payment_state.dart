import 'package:equatable/equatable.dart';

import '../../domain/entities/payment_intent.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentReady extends PaymentState {
  final PaymentIntent intent;

  const PaymentReady(this.intent);

  @override
  List<Object?> get props => [intent];
}

class PaymentSuccess extends PaymentState {}

class PaymentFailed extends PaymentState {
  final String message;

  const PaymentFailed(this.message);

  @override
  List<Object?> get props => [message];
}