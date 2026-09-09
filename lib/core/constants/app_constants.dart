import 'package:flutter/foundation.dart';

class AppConstants {
  static const String appName = 'Pharma';
  static const String userEmailPlaceholder = 'name@example.com';

  static const String storageKeyAccessToken = 'access_token';
  static const String storageKeyRefreshToken = 'refresh_token';
  static const String storageKeyUser = 'current_user';
  static const String storageKeyFavorites = 'favorite_products';
  static const String storageKeyThemeMode = 'theme_mode';

  static const String roleCustomer = 'Customer';
  static const String roleAdmin = 'Admin';
  static const String rolePharmacist = 'Pharmacist';

  static const String paymentMethodCash = 'Cash';
  static const String paymentMethodCard = 'CreditCard';

  static const String _baseUrlOverride =
      String.fromEnvironment('API_BASE_URL');

  /// Set to true only when running on the Android emulator.
  static const bool _isAndroidEmulator =
      bool.fromEnvironment('ANDROID_EMULATOR');

 
  static String get baseUrl {
    if (_baseUrlOverride.isNotEmpty) return _baseUrlOverride;
    if (!kIsWeb &&
        defaultTargetPlatform == TargetPlatform.android &&
        _isAndroidEmulator) {
      return 'http://10.0.2.2:5000/api';
    }
    return 'http://192.168.1.6:5000/api';
  }
}
