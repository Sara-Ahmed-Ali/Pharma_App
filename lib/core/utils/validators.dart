import 'package:flutter/material.dart';

class Validators {
  static final RegExp passwordPolicy = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).+$',
  );

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Email is required';
    final pattern = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!pattern.hasMatch(text)) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return 'Password is required';
    if (text.length < 6) return 'Password must be at least 6 characters';
    if (!passwordPolicy.hasMatch(text)) {
      return 'Password must contain at least one uppercase, lowercase, '
          'number, and special character';
    }
    return null;
  }

  static String? name(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Name is required';
    if (text.length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  static String? quantity(String? value, {int max = 500}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Quantity is required';
    final number = int.tryParse(text);
    if (number == null) return 'Enter a valid number';
    if (number < 1) return 'Quantity must be at least 1';
    if (number > max) return 'Quantity cannot exceed $max';
    return null;
  }

  static String? plainText(String? value, {String? fieldName}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return '${fieldName ?? 'This field'} is required';
    return null;
  }

  static String? shippingAddress(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Shipping address is required';
    if (text.length < 5) return 'Address must be at least 5 characters';
    return null;
  }
}

extension EmailValidator on BuildContext {
  String? validateEmail(String? value) => Validators.email(value);
}