import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EletroDescarte',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00FF87),
          brightness: Brightness.dark,
          primary: const Color(0xFF00FF87),
          secondary: const Color(0xFF38ef7d),
          background: const Color(0xFF0F2027),
        ),
        scaffoldBackgroundColor: const Color(0xFF0F2027),
      ),
      home: const LoginScreen(),
    );
  }
}
