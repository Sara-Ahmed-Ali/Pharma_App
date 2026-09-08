import 'package:dio/dio.dart';

import '../services/secure_storage_service.dart';
import 'api_endpoints.dart';

class AuthInterceptor extends QueuedInterceptor {
  final SecureStorageService _storage;
  final Dio _dio;
  bool _isRefreshing = false;

  AuthInterceptor(this._storage, this._dio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final skipAuth = options.extra['skipAuth'] == true;
    if (skipAuth) {
      options.headers.remove('Authorization');
      return handler.next(options);
    }

    final token = await _storage.getAccessToken();
    if (token != null && token.isNotEmpty && !_isAuthPath(options.path)) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final status = err.response?.statusCode;
    final path = err.requestOptions.path;
    final skipAuth = err.requestOptions.extra['skipAuth'] == true;

    if (status != 401 || _isAuthPath(path) || skipAuth) {
      return handler.next(err);
    }

    try {
      final opts = err.requestOptions;
      final refreshed = await _refreshToken(opts);
      if (refreshed == null) {
        return handler.next(err);
      }
      final response = await _dio.request(
        opts.path,
        data: opts.data,
        queryParameters: opts.queryParameters,
        options: Options(
          method: opts.method,
          headers: {...opts.headers, 'Authorization': 'Bearer $refreshed'},
          contentType: opts.contentType,
          responseType: opts.responseType,
        ),
      );
      return handler.resolve(response);
    } catch (e) {
      return handler.next(err);
    }
  }

  bool _isAuthPath(String path) =>
      path.contains('login') || path.contains('register');

  // Returns the new access token, or null if refresh failed.
  Future<String?> _refreshToken(RequestOptions original) async {
    if (_isRefreshing) return null;

    final refreshToken = await _storage.getRefreshToken();
    final accessToken = await _storage.getAccessToken();
    if (refreshToken == null ||
        refreshToken.isEmpty ||
        accessToken == null ||
        accessToken.isEmpty) {
      return null;
    }

    _isRefreshing = true;
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.refreshToken,
        options: Options(
          headers: {'Authorization': null},
          extra: {'skipAuth': true},
        ),
        data: {'token': accessToken, 'refreshToken': refreshToken},
      );
      final data = response.data;
      if (data == null) return null;

      final newAccess = data['token'] as String?;
      final newRefresh = data['refreshToken'] as String?;
      if (newAccess == null || newAccess.isEmpty) return null;

      await _storage.saveAuthTokens(
        accessToken: newAccess,
        refreshToken: newRefresh ?? refreshToken,
      );
      return newAccess;
    } catch (_) {
      await _storage.clearAll();
      return null;
    } finally {
      _isRefreshing = false;
    }
  }
}