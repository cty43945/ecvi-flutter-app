import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

/// Entry point of the eCVI application.
///
/// This file sets up the top‑level [MaterialApp] and directs users to the
/// [HomeScreen].  The actual business logic and form entry screens live in
/// separate files under the `screens/` directory.
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eCVI Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}