import 'package:flutter/material.dart';

import '../services/secure_storage_service.dart';

class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController._() : super(ThemeMode.light) {
    _restore();
  }

  static final ThemeController instance = ThemeController._();

  bool get isDark {
    switch (value) {
      case ThemeMode.dark:
        return true;
      case ThemeMode.light:
        return false;
      case ThemeMode.system:
        final brightness =
            WidgetsBinding.instance.platformDispatcher.platformBrightness;
        return brightness == Brightness.dark;
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    value = mode;
    await SecureStorageService.instance.saveThemeMode(mode.name);
  }

  Future<void> toggle() async {
    await setMode(isDark ? ThemeMode.light : ThemeMode.dark);
  }

  Future<void> _restore() async {
    final saved = await SecureStorageService.instance.getThemeMode();
    final mode = ThemeMode.values.asNameMap()[saved];
    if (mode != null) {
      value = mode;
    }
  }
}