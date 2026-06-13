import 'package:flutter/material.dart';

class MyRegistrationPage extends StatelessWidget {
  final String studentID;

  const MyRegistrationPage({super.key, required this.studentID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Registration'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: Center(
        child: Text('Registration page for $studentID', style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
