import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/injection/injection.dart';
import 'core/services/stripe_service.dart';
import 'core/theme/app_theme.dart';
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

class PharmaApp extends StatelessWidget {
  const PharmaApp({super.key});

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
          create: (_) => FavoritesBloc(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Pharma App',
        theme: AppTheme.light,
        home: const SplashScreen(),
      ),
    );
  }
}