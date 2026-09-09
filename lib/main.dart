import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/injection/injection.dart';
import 'core/services/stripe_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/pharma_palette.dart';
import 'core/theme/theme_controller.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/cart/presentation/bloc/cart_bloc.dart';
import 'features/orders/presentation/bloc/order_bloc.dart';
import 'features/payment/presentation/bloc/payment_bloc.dart';
import 'features/products/presentation/bloc/catalog_bloc.dart';
import 'features/products/presentation/bloc/favorites_bloc.dart';
import 'features/splash/presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  unawaited(StripeService.instance.initialize());
  runApp(const PharmaApp());
}

class PharmaApp extends StatefulWidget {
  const PharmaApp({super.key});

  @override
  State<PharmaApp> createState() => _PharmaAppState();
}

class _PharmaAppState extends State<PharmaApp> {
  @override
  void initState() {
    super.initState();
    _applySystemUiOverlay(ThemeController.instance.isDark);
    ThemeController.instance.addListener(_onThemeChanged);
  }

  void _onThemeChanged() {
    _applySystemUiOverlay(ThemeController.instance.isDark);
  }

  void _applySystemUiOverlay(bool isDark) {
    SystemChrome.setSystemUIOverlayStyle(
      isDark
          ? SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.dark,
              systemNavigationBarColor: PharmaPalette.dark.surface,
              systemNavigationBarIconBrightness: Brightness.light,
              systemNavigationBarDividerColor: PharmaPalette.dark.border,
            )
          : SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
              systemNavigationBarColor: PharmaPalette.light.surface,
              systemNavigationBarIconBrightness: Brightness.dark,
              systemNavigationBarDividerColor: PharmaPalette.light.border,
            ),
    );
  }

  @override
  void dispose() {
    ThemeController.instance.removeListener(_onThemeChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(getIt()),
        ),
        BlocProvider(
          create: (_) => CatalogBloc(getIt()),
        ),
        BlocProvider(
          create: (_) => CartBloc(getIt()),
        ),
        BlocProvider(
          create: (_) => OrderBloc(getIt()),
        ),
        BlocProvider(
          create: (_) => PaymentBloc(getIt()),
        ),
        BlocProvider(
          create: (_) => FavoritesBloc(getIt()),
        ),
      ],
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: ThemeController.instance,
        builder: (context, themeMode, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Pharma App',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}