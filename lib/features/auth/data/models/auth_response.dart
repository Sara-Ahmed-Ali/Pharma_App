import '../../domain/entities/auth_user.dart';

class AuthResponse {
  final AuthUser user;
  final String accessToken;
  final String refreshToken;

  const AuthResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: AuthUser(
        id: json['userId'] as int,
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        role: json['role'] as String? ?? 'Customer',
      ),
      accessToken: json['token'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
    );
  }
}