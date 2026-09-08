import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/app_constants.dart';

class SecureStorageService {
  SecureStorageService._();
  static final SecureStorageService instance = SecureStorageService._();

  static final FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
  );

  Future<void> saveAuthTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(
      key: AppConstants.storageKeyAccessToken,
      value: accessToken,
    );
    await _storage.write(
      key: AppConstants.storageKeyRefreshToken,
      value: refreshToken,
    );
  }

  Future<String?> getAccessToken() =>
      _storage.read(key: AppConstants.storageKeyAccessToken);

  Future<String?> getRefreshToken() =>
      _storage.read(key: AppConstants.storageKeyRefreshToken);

  Future<void> saveUser(String userJson) async {
    await _storage.write(
      key: AppConstants.storageKeyUser,
      value: userJson,
    );
  }

  Future<String?> getUser() =>
      _storage.read(key: AppConstants.storageKeyUser);

  Future<void> clearAll() async {
    await _storage.delete(key: AppConstants.storageKeyAccessToken);
    await _storage.delete(key: AppConstants.storageKeyRefreshToken);
    await _storage.delete(key: AppConstants.storageKeyUser);
  }
}
