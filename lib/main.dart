import 'package:flutter/material.dart';
// import 'package:my_app/first_page.dart';
import 'package:my_app/Student/student_dashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'St. Andrews University',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A3FBF)),
        useMaterial3: true,
      ),
      home: const StudentDashboard(),
    );
  }
}

