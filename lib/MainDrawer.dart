import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Imports
import 'LoginPage.dart';
import 'manage_fee/pages/FeeSummaryPage.dart';
import 'manage_fee/pages/PaymentHistoryPage.dart';
import 'subject_registration/pages/AddCoursePage.dart';
import 'subject_registration/pages/PendingRegistrationPage.dart';
import 'manage_attendance/pages/LecturerSessionPage.dart';
import 'manage_attendance/pages/LiveSessionPage.dart';
import 'manage_report/pages/ManageReportDashboard.dart';

class MainDrawer extends StatefulWidget {
  const MainDrawer({super.key});

  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  String _userRole = 'Student'; // Default
  String _userId = '';
  bool isBlocked = false;

  @override
  void initState() {
    super.initState();
    _loadRole();
    checkBlockStatus();
  }

  Future<void> _loadRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userRole = prefs.getString('user_role') ?? 'Student';
      _userId = prefs.getString('user_id') ?? 'CB23150';
    });
  }

  Future<void> checkBlockStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String studentId = prefs.getString("student_id") ?? "";

    if (studentId.isEmpty) {
      return;
    }

    try {
      final response = await http.get(
        Uri.parse("http://127.0.0.1:8000/api/block/status/$studentId"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          isBlocked = data["blocked"] ?? false;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
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
              // Blue for student, Indigo for staff
              color: _userRole == 'Staff' ? Colors.indigo : Colors.blue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  _userRole == 'Staff' ? Icons.admin_panel_settings : Icons.school,
                  color: Colors.white,
                  size: 40,
                ),
                const SizedBox(height: 10),
                Text(
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
              leading: const Icon(Icons.pending_actions),
              title: const Text("Pending Registrations"),
              onTap: () {
                Navigator.pop(context); // Close drawer first
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const PendingRegistrationPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.co_present),
              title: const Text('Manage Attendance'),
              onTap: () {
                Navigator.pop(context); 
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
                Navigator.pop(context); 
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
                isBlocked ? Icons.lock : Icons.book,
                color: isBlocked ? Colors.red : Colors.black,
              ),
              title: Text(
                "Subject Registration",
                style: TextStyle(
                  color: isBlocked ? Colors.grey : Colors.black,
                ),
              ),
              onTap: () {
                if (isBlocked) {
                  showDialog(
                    context: context,
                    builder: (_) {
                      return AlertDialog(
                        title: const Text("Academic Access Blocked"),
                        content: const Text("You have outstanding tuition fees.\n\nPlease settle your tuition fee before accessing Subject Registration."),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("OK"),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  Navigator.pop(context); // Close drawer first
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const AddCoursePage()), 
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text("Manage Fee"),
              onTap: () {
                Navigator.pop(context); 
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FeeSummaryPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(
                isBlocked ? Icons.lock : Icons.how_to_reg,
                color: isBlocked ? Colors.red : Colors.black,
              ),
              title: Text(
                'Attendance Check-in', 
                style: TextStyle(
                  color: isBlocked ? Colors.grey : Colors.black,
                ),
              ),
              onTap: () {
                if (isBlocked) {
                  showDialog(
                    context: context,
                    builder: (_) {
                      return AlertDialog(
                        title: const Text("Academic Access Blocked"),
                        content: const Text("Please settle your tuition fee before accessing Attendance."),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("OK"),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  Navigator.pop(context);
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
                }
              },
            ),
            ListTile(
              leading: Icon(
                isBlocked ? Icons.lock : Icons.sports_volleyball,
                color: isBlocked ? Colors.red : Colors.black,
              ),
              title: Text(
                "Co-Curriculum",
                style: TextStyle(
                  color: isBlocked ? Colors.grey : Colors.black,
                ),
              ),
              onTap: () {
                if (isBlocked) {
                  showDialog(
                    context: context,
                    builder: (_) {
                      return AlertDialog(
                        title: const Text("Academic Access Blocked"),
                        content: const Text("Please settle your tuition fee before accessing Co-Curriculum."),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("OK"),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  Navigator.pop(context);
                }
              },
            ),
          ],

          const Divider(),

          // --- LOGOUT BUTTON ---
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
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