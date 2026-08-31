import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const PharmaApp());
}

class PharmaApp extends StatelessWidget {
  const PharmaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pharma App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF007A78)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}