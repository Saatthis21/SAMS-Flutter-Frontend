import 'package:flutter/material.dart';
import 'LoginPage.dart';

// Import your pages
import 'manage_fee/pages/PaymentPage.dart';
import 'manage_fee/pages/ReceiptPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SAMS App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      // First page
      home: LoginPage(),

      // Register named routes
      routes: {
        "/payment": (context) => const PaymentPage(),
        "/receipt": (context) => const ReceiptPage(),
      },
    );
  }
}