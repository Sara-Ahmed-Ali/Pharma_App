import 'package:flutter_stripe/flutter_stripe.dart';

/// Stripe publishable key.
///
/// Provide your real key at build/run time:
///   flutter run --dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_xxx
/// The fallback below is a placeholder and will NOT process payments.
const String kStripePublishableKey = String.fromEnvironment(
  'STRIPE_PUBLISHABLE_KEY',
  defaultValue: 'pk_test_XXXXXXXXXXXXXXXXXXXXXXXX',
);

class StripeService {
  StripeService._();

  static final StripeService instance = StripeService._();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    Stripe.publishableKey = kStripePublishableKey;
    _initialized = true;
  }

  /// Presents the native Stripe payment sheet for a given client secret.
  /// Returns `true` when the payment was confirmed successfully.
  Future<bool> presentPaymentSheet(String clientSecret) async {
    await initialize();

    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'Pharma',
      ),
    );

    await Stripe.instance.presentPaymentSheet();
    return true;
  }
}