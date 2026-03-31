import 'package:flutter/material.dart';
import 'package:my_app/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Dahiwadi College",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 26, 63, 191),
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}