class AuthUser {
  final int id;
  final String name;
  final String email;
  final String role;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  String get initial => name.isNotEmpty ? name[0].toUpperCase() : '?';

  bool get isCustomer => role == 'Customer';

  bool get isAdmin => role == 'Admin';

  bool get isPharmacist => role == 'Pharmacist';

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
      };

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: json['id'] as int,
        name: json['name'] as String,
        email: json['email'] as String,
        role: json['role'] as String,
      );
}