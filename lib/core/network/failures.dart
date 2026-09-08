import 'package:dio/dio.dart';

sealed class AppException implements Exception {
  final String message;

  const AppException(this.message);

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException(super.message);
}

class ServerException extends AppException {
  const ServerException(super.message);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message);
}

class NotFoundException extends AppException {
  const NotFoundException(super.message);
}

class BadRequestException extends AppException {
  const BadRequestException(super.message);
}

class UnknownException extends AppException {
  const UnknownException(super.message);
}

class Failure {
  final String message;

  const Failure(this.message);
}

Failure mapDioExceptionToFailure(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const Failure('Connection timed out. Please try again.');
      case DioExceptionType.connectionError:
        return const Failure(
          'Unable to connect to the server. Check your connection.',
        );
      case DioExceptionType.badResponse:
        final status = error.response?.statusCode;
        final data = error.response?.data;
        final message = _extractMessage(data);

        switch (status) {
          case 400:
            return Failure(
              message ?? 'Invalid request. Please check your data.',
            );
          case 401:
            return const Failure('Session expired. Please log in again.');
          case 404:
            return Failure(message ?? 'Requested resource was not found.');
          case 429:
            return const Failure(
              'Too many attempts. Please wait a moment and try again.',
            );
          default:
            return Failure(message ?? 'Something went wrong on the server.');
        }
      default:
        return const Failure('Something went wrong. Please try again.');
    }
  }

  return const Failure('An unexpected error occurred.');
}

String? _extractMessage(dynamic data) {
  if (data is Map) {
    final message = data['message'] ?? data['Message'] ?? data['title'];
    if (message is String && message.isNotEmpty) return message;
    if (data['errors'] is Map) {
      final errors = data['errors'] as Map;
      if (errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) return first.first.toString();
      }
    }
  }
  return null;
}
