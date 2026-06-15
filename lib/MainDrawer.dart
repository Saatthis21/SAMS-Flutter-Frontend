import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  String _userRole = 'Student'; // Default
  String _userId = ''; // Added to pass to your attendance pages

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  // Look inside the vault to see who is logged in
  Future<void> _loadRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userRole = prefs.getString('user_role') ?? 'Student';
      // Ideally, you also save and retrieve the user's ID during login
      _userId = prefs.getString('user_id') ?? 'CB23150';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // --- DYNAMIC HEADER ---
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
                  _userRole == 'Staff'
                      ? Icons.admin_panel_settings
                      : Icons.school,
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

          // --- DYNAMIC MENU ITEMS ---
          if (_userRole == 'Staff') ...[
            // SHOW ONLY TO STAFF
            ListTile(
              leading: const Icon(Icons.pending_actions),
              title: const Text('Pending Registrations'),
              onTap: () {
                Navigator.pop(context); // Close drawer first
                Navigator.pushReplacement(
                  context,
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
          ] else ...[
            // SHOW ONLY TO STUDENTS
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Subject Registration'),
              onTap: () {
                Navigator.pop(context); // Close drawer first
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => AddCoursePage()),
                );
              },
            ),
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
              leading: const Icon(Icons.sports_volleyball),
              title: const Text('Co-Curriculum'),
              onTap: () {}, // Arifah's module
            ),
          ],

          const Divider(),

          // --- LOGOUT BUTTON ---
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              // ALWAYS CLEAR THE VAULT ON LOGOUT
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
