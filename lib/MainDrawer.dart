import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'LoginPage.dart';
import 'manage_fee/pages/FeeSummaryPage.dart';
import 'manage_fee/pages/PaymentHistoryPage.dart';
import 'subject_registration/pages/AddCoursePage.dart';
import 'subject_registration/pages/PendingRegistrationPage.dart';
// Teammate's imports
import 'subject_registration/pages/AddCoursePage.dart';
import 'subject_registration/pages/PendingRegistrationPage.dart';
import 'LoginPage.dart';
// Manage Attendance
import 'manage_attendance/pages/LecturerSessionPage.dart';
import 'manage_attendance/pages/LiveSessionPage.dart';
// Manage Reports
import 'manage_report/pages/ManageReportDashboard.dart'; // Adjust path if needed

class MainDrawer extends StatefulWidget {
  const MainDrawer({super.key});

  @override
  State<MainDrawer> createState() =>
      _MainDrawerState();
}

class _MainDrawerState
    extends State<MainDrawer> {

  String _userRole = "Student";

  bool isBlocked = false;
class _MainDrawerState extends State<MainDrawer> {
  String _userRole = 'Student'; // Default
  String _userId = ''; // Added to pass to your attendance pages

  @override
  void initState() {
    super.initState();

    _loadRole();

    checkBlockStatus();
  }

  Future<void> _loadRole() async {

    SharedPreferences prefs =
        await SharedPreferences.getInstance();

    setState(() {

      _userRole =
          prefs.getString("user_role") ??
              "Student";

      _userRole = prefs.getString('user_role') ?? 'Student';
      // Ideally, you also save and retrieve the user's ID during login
      _userId = prefs.getString('user_id') ?? 'CB23150';
    });

  }

  Future<void> checkBlockStatus() async {

    SharedPreferences prefs =
        await SharedPreferences.getInstance();

    String studentId =
        prefs.getString("student_id") ?? "";

    if (studentId.isEmpty) {
      return;
    }

    try {

      final response = await http.get(

        Uri.parse(

          "http://127.0.0.1:8000/api/block/status/$studentId",

        ),

      );

      if (response.statusCode == 200) {

        final data =
            jsonDecode(response.body);

        setState(() {

          isBlocked =
              data["blocked"] ?? false;

        });

      }

    } catch (e) {

      debugPrint(
        e.toString(),
      );

    }

  }
  @override
  Widget build(BuildContext context) {

    return Drawer(

      child: ListView(

        padding: EdgeInsets.zero,

        children: [

          DrawerHeader(

            decoration: BoxDecoration(

              color: _userRole == "Staff"

                  ? Colors.indigo

                  : Colors.blue,

              // Blue for student, Indigo for staff
              color: _userRole == 'Staff' ? Colors.indigo : Colors.blue,
            ),

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              mainAxisAlignment:
                  MainAxisAlignment.end,

              children: [

                Icon(

                  _userRole == "Staff"

                      ? Icons.admin_panel_settings

                      : Icons.school,

                  color: Colors.white,

                  size: 40,

                  _userRole == 'Staff'
                      ? Icons.admin_panel_settings
                      : Icons.school,
                  color: Colors.white,
                  size: 40,
                ),

                const SizedBox(
                  height: 10,
                ),

                Text(

                  _userRole == "Staff"

                      ? "UMPSA SAMS\nSTAFF DASHBOARD"

                      : "UMPSA SAMS\nSTUDENT PORTAL",

                  style: const TextStyle(

                    color: Colors.white,

                    fontSize: 20,

                    fontWeight: FontWeight.bold,

                  ),

                  _userRole == 'Staff'
                      ? 'UMPSA SAMS\nSTAFF DASHBOARD'
                      : 'UMPSA SAMS\nSTUDENT PORTAL',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              ],

            ),

          ),

          //==========================
          // STAFF MENU
          //==========================

          if (_userRole == "Staff") ...[

            ListTile(

              leading:
                  const Icon(Icons.pending_actions),

              title: const Text(
                  "Pending Registrations"),

              onTap: () {

                Navigator.pop(context); // Close drawer first
                Navigator.pushReplacement(

                  context,

                  MaterialPageRoute(

                    builder: (_) =>
                        PendingRegistrationPage(),

                  ),

                  MaterialPageRoute(
                    builder: (context) => PendingRegistrationPage(),
                  ),
                );
              },
            ),
            // ---> YOUR LECTURER ATTENDANCE ROUTE <---
            ListTile(
              leading: const Icon(Icons.co_present),
              title: const Text('Manage Attendance'),
              onTap: () {
                Navigator.pop(context); // Close the drawer smoothly
                // Using standard push() so the Back Button works!
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LecturerSessionPage(
                      lecturerID: _userId,
                      subjectCode: 'BCS2173',
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Manage Reports'),
              onTap: () {
                Navigator.pop(context); // Close the drawer smoothly
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ManageReportDashboard(),
                  ),
                );

              },

            ),

          ]

          //==========================
          // STUDENT MENU
          //==========================

          else ...[

            ListTile(

              leading: Icon(

                isBlocked

                    ? Icons.lock

                    : Icons.book,

                color: isBlocked

                    ? Colors.red

                    : Colors.black,

              ),

              title: Text(

                "Subject Registration",

                style: TextStyle(

                  color: isBlocked

                      ? Colors.grey

                      : Colors.black,

                ),

              ),

              onTap: () {

                if (isBlocked) {

                  showDialog(

                    context: context,

                    builder: (_) {

                      return AlertDialog(

                        title: const Text(

                          "Academic Access Blocked",

                        ),

                        content: const Text(

                          "You have outstanding tuition fees.\n\nPlease settle your tuition fee before accessing Subject Registration.",

                        ),

                        actions: [

                          TextButton(

                            onPressed: () {

                              Navigator.pop(
                                  context);

                            },

                            child: const Text(
                              "OK",
                            ),

                          ),

                        ],

                      );

                    },

                  );

                } else {

                  Navigator.pushReplacement(

                    context,

                    MaterialPageRoute(

                      builder: (_) =>
                          AddCoursePage(),

                    ),

                  );

                }

                Navigator.pop(context); // Close drawer first
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => AddCoursePage()),
                );
              },

            ),

            ListTile(

              leading: const Icon(

                Icons.account_balance_wallet,

              ),

              title:
                  const Text("Manage Fee"),

              onTap: () {

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (_) =>
                        const FeeSummaryPage(),

                  ),

                );

              },

            // ---> YOUR STUDENT ATTENDANCE ROUTE <---
            ListTile(
              leading: const Icon(Icons.how_to_reg),
              title: const Text('Attendance Check-in'),
              onTap: () {
                Navigator.pop(context); // Close the drawer smoothly
                // Using standard push() so the Back Button works!
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LiveSessionPage(
                      studentID: _userId,
                      sessionId: 1,
                      subjectCode: 'BCS2173',
                    ),
                  ),
                );
              },
            ),

        

           ListTile(

  leading: Icon(

    isBlocked
        ? Icons.lock
        : Icons.how_to_reg,

    color:
        isBlocked
            ? Colors.red
            : Colors.black,

  ),

  title: Text(

    "Attendance",

    style: TextStyle(

      color:
          isBlocked
              ? Colors.grey
              : Colors.black,

    ),

  ),

  onTap: () {

    if (isBlocked) {

      showDialog(

        context: context,

        builder: (_) {

          return const AlertDialog(

            title: Text(
              "Academic Access Blocked",
            ),

            content: Text(
              "Please settle your tuition fee before accessing Attendance.",
            ),

          );

        },

      );

    } else {

      // Attendance Module

    }

  },

),

           ListTile(

  leading: Icon(

    isBlocked
        ? Icons.lock
        : Icons.sports_volleyball,

    color:
        isBlocked
            ? Colors.red
            : Colors.black,

  ),

  title: Text(

    "Co-Curriculum",

    style: TextStyle(

      color:
          isBlocked
              ? Colors.grey
              : Colors.black,

    ),

  ),

  onTap: () {

    if (isBlocked) {

      showDialog(

        context: context,

        builder: (_) {

          return const AlertDialog(

            title: Text(
              "Academic Access Blocked",
            ),

            content: Text(
              "Please settle your tuition fee before accessing Co-Curriculum.",
            ),

          );

        },

      );

    } else {

      // Co-Curriculum Module

    }

  },

),


          ],

          const Divider(),

          // --- LOGOUT BUTTON ---
          ListTile(

            leading: const Icon(

              Icons.logout,

              color: Colors.red,

            ),

            title: const Text(

              "Logout",

              style:
                  TextStyle(color: Colors.red),

            ),

            onTap: () async {

              SharedPreferences prefs =
                  await SharedPreferences
                      .getInstance();

              // ALWAYS CLEAR THE VAULT ON LOGOUT
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              if (mounted) {

                Navigator.pushAndRemoveUntil(

                  context,

                  MaterialPageRoute(

                    builder: (_) =>
                        const LoginPage(),

                  ),

                  (route) => false,

                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );

              }

            },

          ),

        ],

      ),

    );

  }

}
