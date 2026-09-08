import 'package:flutter/foundation.dart';

class AppConstants {
  static const String appName = 'Pharma';
  static const String userEmailPlaceholder = 'name@example.com';

  static const String storageKeyAccessToken = 'access_token';
  static const String storageKeyRefreshToken = 'refresh_token';
  static const String storageKeyUser = 'current_user';

  static const String roleCustomer = 'Customer';
  static const String roleAdmin = 'Admin';
  static const String rolePharmacist = 'Pharmacist';

  static const String paymentMethodCash = 'Cash';
  static const String paymentMethodCard = 'CreditCard';

  /// Override at build/run time:
  ///   flutter run --dart-define=API_BASE_URL=http://192.168.1.5:7081/api
  static const String _baseUrlOverride =
      String.fromEnvironment('API_BASE_URL');

  /// Set to true only when running on the Android emulator.
  ///   flutter run --dart-define=ANDROID_EMULATOR=true
  static const bool _isAndroidEmulator =
      bool.fromEnvironment('ANDROID_EMULATOR');

  /// Base URL for the Pharma backend API.
  ///
  /// Resolution order:
  ///  1. `API_BASE_URL` passed via --dart-define.
  ///  2. Android emulator -> 10.0.2.2 (host machine loopback).
  ///  3. Anything else (including a physical Android phone) -> the dev
  ///     machine LAN IP where the backend runs.
  static String get baseUrl {
    if (_baseUrlOverride.isNotEmpty) return _baseUrlOverride;
    if (!kIsWeb &&
        defaultTargetPlatform == TargetPlatform.android &&
        _isAndroidEmulator) {
      return 'http://10.0.2.2:5000/api';
    }
    return 'http://192.168.1.5:5000/api';
  }
}
