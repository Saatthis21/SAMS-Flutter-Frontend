import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'config/api.dart';

import 'subject_registration/pages/AddCoursePage.dart';
import 'subject_registration/pages/PendingRegistrationPage.dart';

import 'manage_fee/pages/TreasuryDashboardPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final TextEditingController _idController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  bool _isLoading = false;

  String selectedRole = "Student";

  Future<void> _login() async {

    // ===================================
    // STAFF LOGIN (Existing Module)
    // ===================================

    if (selectedRole == "Staff") {

      if (_idController.text == "admin" &&
          _passwordController.text == "admin123") {

        SharedPreferences prefs =
            await SharedPreferences.getInstance();

        await prefs.setString(
            "user_role", "Staff");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PendingRegistrationPage(),
          ),
        );

      } else {

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
                "Invalid Staff ID or Password"),
            backgroundColor: Colors.red,
          ),
        );

      }

      return;
    }

    // ===================================
    // TREASURY LOGIN (YOUR MODULE)
    // ===================================

    if (selectedRole == "Treasury") {

      if (_idController.text == "treasury" &&
          _passwordController.text ==
              "treasury123") {

        SharedPreferences prefs =
            await SharedPreferences
                .getInstance();

        await prefs.setString(
            "user_role", "Treasury");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const TreasuryDashboard(),
          ),
        );

      } else {

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
                "Invalid Treasury ID or Password"),
            backgroundColor: Colors.red,
          ),
        );

      }

      return;
    }

    // ===================================
    // STUDENT LOGIN (UNCHANGED)
    // ===================================

    setState(() {

      _isLoading = true;

    });

    try {

      final response = await http.post(

        Uri.parse(
            '${ApiConfig.baseUrl}/login'),

        headers: {

          'Content-Type':
              'application/json',

        },

        body: json.encode({

          'student_id':
              _idController.text,

          'password':
              _passwordController.text,

        }),

      );

      final data =
          json.decode(response.body);

      if (response.statusCode == 200 &&
          data["success"] == true) {

        SharedPreferences prefs =
            await SharedPreferences
                .getInstance();

        await prefs.setString(
            "user_role", "Student");

        await prefs.setString(
            "student_id",
            data["student_id"]);

        await prefs.setString(
            "student_name",
            data["student_name"]);

        await prefs.setString(
            "student_course",
            data["student_course"]);

        await prefs.setInt(
            "student_year",
            int.parse(data["student_year"]
                .toString()));

        if (mounted) {

          Navigator.pushReplacement(

            context,

            MaterialPageRoute(

              builder: (context) =>
                  AddCoursePage(),

            ),

          );

        }

      } else {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          SnackBar(

            content: Text(

              data["message"] ??
                  "Login Failed",

            ),

            backgroundColor:
                Colors.red,

          ),

        );

      }

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          content: Text(
              "Error : $e"),

          backgroundColor:
              Colors.red,

        ),

      );

    }

    setState(() {

      _isLoading = false;

    });

  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.grey.shade100,

      body: Center(

        child: SingleChildScrollView(

          padding: const EdgeInsets.all(24),

          child: Column(

            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [

              const Icon(
                Icons.school,
                size: 80,
                color: Colors.blue,
              ),

              const SizedBox(height: 20),

              Text(

                "$selectedRole Login",

                style: const TextStyle(

                  fontSize: 28,

                  fontWeight: FontWeight.bold,

                ),

              ),

              const SizedBox(height: 40),

              TextField(

                controller: _idController,

                decoration: InputDecoration(

                  labelText:

                      selectedRole == "Student"

                          ? "Student ID"

                          : selectedRole == "Staff"

                              ? "Staff ID"

                              : "Treasury ID",

                  filled: true,

                  fillColor: Colors.white,

                  border: OutlineInputBorder(

                    borderRadius:

                        BorderRadius.circular(12),

                  ),

                ),

              ),

              const SizedBox(height: 16),

              TextField(

                controller:

                    _passwordController,

                obscureText: true,

                decoration: InputDecoration(

                  labelText: "Password",

                  filled: true,

                  fillColor: Colors.white,

                  border: OutlineInputBorder(

                    borderRadius:

                        BorderRadius.circular(12),

                  ),

                ),

              ),

              const SizedBox(height: 30),

              DropdownButtonFormField<String>(

                value: selectedRole,

                decoration: InputDecoration(

                  labelText: "Select Role",

                  filled: true,

                  fillColor: Colors.white,

                  border: OutlineInputBorder(

                    borderRadius:

                        BorderRadius.circular(12),

                  ),

                ),

                items: [

                  "Student",

                  "Staff",

                  "Treasury",

                ].map(

                  (role) => DropdownMenuItem(

                    value: role,

                    child: Text(

                      role,

                      style: const TextStyle(

                        fontWeight:

                            FontWeight.bold,

                      ),

                    ),

                  ),

                ).toList(),

                onChanged: (value) {

                  setState(() {

                    selectedRole = value!;

                  });

                },

              ),

              const SizedBox(height: 30),

              _isLoading

                  ? const CircularProgressIndicator()

                  : SizedBox(

                      width: double.infinity,

                      height: 50,

                      child: ElevatedButton(

                        style:

                            ElevatedButton.styleFrom(

                          backgroundColor:

                              Colors.blue.shade800,

                          shape:

                              RoundedRectangleBorder(

                            borderRadius:

                                BorderRadius.circular(12),

                          ),

                        ),

                        onPressed: _login,

                        child: const Text(

                          "LOGIN",

                          style: TextStyle(

                            color: Colors.white,

                            fontSize: 16,

                            fontWeight:

                                FontWeight.bold,

                          ),

                        ),

                      ),

                    ),

            ],

          ),

        ),

      ),

    );

  }

}
