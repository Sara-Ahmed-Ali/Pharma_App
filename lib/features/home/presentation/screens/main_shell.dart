import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_navigation.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_event.dart';
import '../../../cart/presentation/screens/cart_screen.dart';
import '../../../orders/presentation/bloc/order_bloc.dart';
import '../../../orders/presentation/bloc/order_event.dart';
import '../../../orders/presentation/screens/orders_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import 'home_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  @override
  void initState() {
    super.initState();
    mainTabIndex.value = 0;
    mainTabIndex.addListener(_onTabChanged);
    context.read<CartBloc>().add(const CartFetchRequested());
  }

  @override
  void dispose() {
    mainTabIndex.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onTabChanged() {
    if (mainTabIndex.value == 2) {
      context.read<OrderBloc>().add(const OrdersFetchRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState is AuthAuthenticated
        ? authState.user
        : authState is ProfileUpdated
            ? authState.user
            : null;

    final screens = [
      const HomeScreen(),
      const CartScreen(),
      const OrdersScreen(),
      if (user != null) ProfileScreen(user: user),
    ];

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      },
      child: ValueListenableBuilder<int>(
        valueListenable: mainTabIndex,
        builder: (context, index, _) {
          final safeIndex = index.clamp(0, screens.length - 1);
          return Scaffold(
            body: IndexedStack(index: safeIndex, children: screens),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: safeIndex,
        onTap: (tappedIndex) {
            setState(() => mainTabIndex.value = tappedIndex);
          },
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.shopping_cart_outlined),
              activeIcon: const Icon(Icons.shopping_cart_rounded),
              label: 'Cart',
              tooltip: 'Cart',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long_rounded),
              label: 'Orders',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
          ),
        );
        },
      ),
    );
  }
}