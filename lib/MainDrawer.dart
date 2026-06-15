import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'LoginPage.dart';
import 'manage_fee/pages/FeeSummaryPage.dart';
import 'manage_fee/pages/PaymentHistoryPage.dart';
import 'subject_registration/pages/AddCoursePage.dart';
import 'subject_registration/pages/PendingRegistrationPage.dart';

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

                Navigator.pushReplacement(

                  context,

                  MaterialPageRoute(

                    builder: (_) =>
                        PendingRegistrationPage(),

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

              await prefs.clear();

              if (mounted) {

                Navigator.pushAndRemoveUntil(

                  context,

                  MaterialPageRoute(

                    builder: (_) =>
                        const LoginPage(),

                  ),

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
