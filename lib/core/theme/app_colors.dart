import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF007A78);
  static const Color primaryDark = Color(0xFF005C5A);
  static const Color primaryLight = Color(0xFFE0F2F1);

  static const Color secondary = Color(0xFF0B7285);
  static const Color accent = Color(0xFF2FB3A6);

  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textHint = Color(0xFF94A3B8);

  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;

  static const Color error = Color(0xFFDC2626);
  static const Color success = Color(0xFF16A34A);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF007A78), Color(0xFF0B7285)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
