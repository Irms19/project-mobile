
import 'package:flutter/material.dart';
import 'adminlogin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Venue Hall Booking Admin',
      home: const AdminLoginPage(),
    );
  }
}