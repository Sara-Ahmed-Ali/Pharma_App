import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/failures.dart';
import '../../domain/repositories/payment_repository.dart';
import 'payment_event.dart';
import 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final PaymentRepository _paymentRepository;

  PaymentBloc(this._paymentRepository) : super(PaymentInitial()) {
    on<CreatePaymentIntent>(_onCreateIntent);
    on<ResetPaymentStatus>(_onReset);
  }

  Future<void> _onCreateIntent(
    CreatePaymentIntent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(PaymentLoading());
    try {
      final intent = await _paymentRepository.createPaymentIntent(
        orderId: event.orderId,
        currency: event.currency,
      );
      emit(PaymentReady(intent));
    } catch (e) {
      emit(PaymentFailed(_messageOf(e)));
    }
  }

  void _onReset(ResetPaymentStatus event, Emitter<PaymentState> emit) {
    emit(PaymentInitial());
  }

  String _messageOf(Object error) {
    if (error is Failure) return error.message;
    if (error is AppException) return error.message;
    return 'An unexpected error occurred.';
  }
}