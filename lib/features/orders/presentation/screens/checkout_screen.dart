import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/stripe_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/common/app_text_field.dart';
import '../../../../core/widgets/common/buttons.dart';
import '../../../cart/domain/entities/cart.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_event.dart';
import '../../../payment/presentation/bloc/payment_bloc.dart';
import '../../../payment/presentation/bloc/payment_event.dart';
import '../../../payment/presentation/bloc/payment_state.dart';
import '../bloc/order_bloc.dart';
import '../bloc/order_event.dart';
import '../bloc/order_state.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final Cart cart;

  const CheckoutScreen({super.key, required this.cart});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _governorateController = TextEditingController();
  final _cityController = TextEditingController();
  final _streetController = TextEditingController();
  final _detailsController = TextEditingController();
  final _landmarkController = TextEditingController();
  bool _isCardPayment = false;
  bool _presentingSheet = false;

  @override
  void dispose() {
    _governorateController.dispose();
    _cityController.dispose();
    _streetController.dispose();
    _detailsController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  String _composeShippingAddress() {
    final parts = <String>[
      _governorateController.text.trim(),
      _cityController.text.trim(),
      _streetController.text.trim(),
      if (_detailsController.text.trim().isNotEmpty)
        _detailsController.text.trim(),
      if (_landmarkController.text.trim().isNotEmpty)
        _landmarkController.text.trim(),
    ];
    return parts.where((p) => p.isNotEmpty).join(', ');
  }

  void _submitOrder() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    context.read<OrderBloc>().add(
          OrderSubmitRequested(
            shippingAddress: _composeShippingAddress(),
            paymentMethod: _isCardPayment
                ? AppConstants.paymentMethodCard
                : AppConstants.paymentMethodCash,
          ),
        );
  }

  Future<void> _runCardPayment(int orderId) async {
    context.read<PaymentBloc>().add(CreatePaymentIntent(orderId: orderId));
  }

  Future<void> _presentStripeSheet(PaymentReady state) async {
    try {
      final paid = await StripeService.instance
          .presentPaymentSheet(state.intent.clientSecret);
      _finish(state.intent.orderId, paid: paid);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment not completed. Order remains pending.'),
        ),
      );
      _finish(state.intent.orderId, paid: false);
    }
  }

  void _finish(int orderId, {required bool paid}) {
    context.read<CartBloc>().add(const CartCleared());
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => OrderSuccessScreen(
          orderId: orderId,
          paymentAttempted: paid,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentBloc, PaymentState>(
      listener: (context, state) {
        if (state is PaymentReady && !_presentingSheet) {
          _presentingSheet = true;
          _presentStripeSheet(state);
        }
        if (state is PaymentFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Checkout')),
        body: BlocConsumer<OrderBloc, OrderState>(
          listener: (context, state) {
            if (state is OrderSubmitted) {
              if (state.order.paymentMethod.toLowerCase() == 'creditcard') {
                _runCardPayment(state.order.id);
              } else {
                _finish(state.order.id, paid: false);
              }
            }
            if (state is OrderError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            final isSubmitting = state is OrderSubmitting;

            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildReviewSection(),
                  const SizedBox(height: 20),
                  _buildPaymentSection(),
                  const SizedBox(height: 20),
                  _buildAddressSection(),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: isSubmitting
                        ? 'Placing order...'
                        : 'Place Order · ${Formatters.currency(widget.cart.totalPrice)}',
                    isLoading: isSubmitting,
                    onPressed: isSubmitting ? null : _submitOrder,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'By placing this order you agree to our terms & conditions.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textHint,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildReviewSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EDF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Review',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...widget.cart.items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${item.productName} × ${item.quantity}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    Formatters.currency(item.subTotal),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                Formatters.currency(widget.cart.totalPrice),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EDF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Method',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _PaymentOption(
            icon: Icons.payments_outlined,
            title: 'Cash on Delivery',
            subtitle: 'Pay when you receive your order',
            selected: !_isCardPayment,
            onTap: () => setState(() => _isCardPayment = false),
          ),
          const SizedBox(height: 10),
          _PaymentOption(
            icon: Icons.credit_card_rounded,
            title: 'Credit / Debit Card',
            subtitle: 'Secure payment via Stripe',
            selected: _isCardPayment,
            onTap: () => setState(() => _isCardPayment = true),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EDF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Shipping Address',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Enter your full address in detail',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _governorateController,
            label: 'Governorate',
            hintText: 'e.g. Cairo',
            prefixIcon: Icons.location_city_outlined,
            validator: (value) =>
                Validators.plainText(value, fieldName: 'Governorate'),
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _cityController,
            label: 'City / District',
            hintText: 'e.g. Nasr City',
            prefixIcon: Icons.map_outlined,
            validator: (value) =>
                Validators.plainText(value, fieldName: 'City / District'),
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _streetController,
            label: 'Street & Building',
            hintText: 'Street name and building no.',
            prefixIcon: Icons.home_outlined,
            validator: (value) =>
                Validators.plainText(value, fieldName: 'Street & Building'),
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _detailsController,
            label: 'Floor & Apartment',
            hintText: 'e.g. Floor 3, Apartment 5',
            prefixIcon: Icons.meeting_room_outlined,
            validator: (value) =>
                Validators.plainText(value, fieldName: 'Floor & Apartment'),
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _landmarkController,
            label: 'Landmark (optional)',
            hintText: 'e.g. Next to the mosque',
            prefixIcon: Icons.place_outlined,
          ),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: selected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? AppColors.primaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: selected ? AppColors.primary : const Color(0xFFCBD5E1),
            ),
          ],
        ),
      ),
    );
  }
}