import 'package:flutter/material.dart';
import '../../MainDrawer.dart'; // Keeps the team menu working here too!

class PendingRegistrationPage extends StatefulWidget {
  const PendingRegistrationPage({super.key});

  @override
  State<PendingRegistrationPage> createState() => _PendingRegistrationPageState();
}

class _PendingRegistrationPageState extends State<PendingRegistrationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PENDING REGISTRATIONS'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      drawer: const MainDrawer(), 
      body: const Center(
        child: Text(
          "Staff Dashboard\nPending Student Lists will appear here.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}