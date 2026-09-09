import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/failures.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/auth_response.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;
  final SecureStorageService _storage;

  AuthRepositoryImpl(this._dio, this._storage);

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.login,
        data: {'email': email.trim(), 'password': password},
      );
      return _handleAuthResponse(response.data);
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }

  @override
  Future<AuthUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.register,
        data: {
          'name': name.trim(),
          'email': email.trim(),
          'password': password,
        },
      );
      return _handleAuthResponse(response.data);
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }

  @override
  Future<AuthUser> getCurrentUser() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(ApiEndpoints.me);
      final user = AuthUser(
        id: response.data!['userId'] as int,
        name: response.data!['name'] as String? ?? '',
        email: response.data!['email'] as String? ?? '',
        role: response.data!['role'] as String? ?? 'Customer',
      );
      await _cacheUser(user);
      return user;
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }

  @override
  Future<AuthUser> updateProfile({
    required String name,
    required String email,
    required String currentPassword,
    String? newPassword,
  }) async {
    try {
      final body = <String, dynamic>{
        'name': name.trim(),
        'email': email.trim(),
      };
      if (currentPassword.isNotEmpty) {
        body['currentPassword'] = currentPassword;
      }
      if (newPassword != null && newPassword.isNotEmpty) {
        body['newPassword'] = newPassword;
      }
      final response = await _dio.put<Map<String, dynamic>>(
        ApiEndpoints.updateProfile,
        data: body,
      );
      final user = AuthUser(
        id: response.data!['userId'] as int,
        name: response.data!['name'] as String? ?? '',
        email: response.data!['email'] as String? ?? '',
        role: response.data!['role'] as String? ?? 'Customer',
      );
      await _cacheUser(user);
      return user;
    } on DioException catch (e) {
      throw mapDioExceptionToFailure(e);
    }
  }

  @override
  Future<void> logout() => _storage.clearAll();

  @override
  Future<AuthUser?> getCachedUser() async {
    final raw = await _storage.getUser();
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return AuthUser.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  AuthUser _handleAuthResponse(Map<String, dynamic>? data) {
    if (data == null) {
      throw const Failure('Invalid server response.');
    }
    final response = AuthResponse.fromJson(data);
    if (response.accessToken.isEmpty || response.refreshToken.isEmpty) {
      throw const Failure('Invalid response from server.');
    }
    _storage.saveAuthTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );
    _cacheUser(response.user);
    return response.user;
  }

  Future<void> _cacheUser(AuthUser user) =>
      _storage.saveUser(jsonEncode(user.toJson()));
}