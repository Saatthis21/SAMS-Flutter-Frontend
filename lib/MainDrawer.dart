import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'LoginPage.dart';
import 'manage_fee/pages/FeeSummaryPage.dart';
import 'manage_attendance/pages/LecturerSessionPage.dart';
import 'manage_attendance/pages/LiveSessionPage.dart';
import 'manage_report/pages/ManageReportDashboard.dart';
import 'subject_registration/pages/AddCoursePage.dart';
import 'subject_registration/pages/PendingRegistrationPage.dart';

class MainDrawer extends StatefulWidget {
  const MainDrawer({super.key});

  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  String _userRole = 'Student';
  String _userId = '';
  bool isBlocked = false;

  @override
  void initState() {
    super.initState();
    _loadRole();
    checkBlockStatus();
  }

  Future<void> _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userRole = prefs.getString('user_role') ?? 'Student';
      _userId = prefs.getString('user_id') ?? 'CB23150';
    });
  }

  Future<void> checkBlockStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final studentId = prefs.getString('student_id') ?? '';

    if (studentId.isEmpty) return;

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/block/status/$studentId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          isBlocked = data['blocked'] ?? false;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _showBlockedDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
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
          if (_userRole == 'Staff') ...[
            ListTile(
              leading: const Icon(Icons.pending_actions),
              title: const Text('Pending Registrations'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PendingRegistrationPage(),
                  ),
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
          ] else ...[
            ListTile(
              leading: Icon(
                isBlocked ? Icons.lock : Icons.book,
                color: isBlocked ? Colors.red : Colors.black,
              ),
              title: Text(
                'Subject Registration',
                style: TextStyle(
                  color: isBlocked ? Colors.grey : Colors.black,
                ),
              ),
              onTap: () {
                if (isBlocked) {
                  _showBlockedDialog(
                    context,
                    'Academic Access Blocked',
                    'You have outstanding tuition fees.\n\nPlease settle your tuition fee before accessing Subject Registration.',
                  );
                  return;
                }
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddCoursePage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text('Manage Fee'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FeeSummaryPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.how_to_reg),
              title: const Text('Attendance Check-in'),
              onTap: () {
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
              },
            ),
            ListTile(
              leading: Icon(
                isBlocked ? Icons.lock : Icons.sports_volleyball,
                color: isBlocked ? Colors.red : Colors.black,
              ),
              title: Text(
                'Co-Curriculum',
                style: TextStyle(
                  color: isBlocked ? Colors.grey : Colors.black,
                ),
              ),
              onTap: () {
                if (isBlocked) {
                  _showBlockedDialog(
                    context,
                    'Academic Access Blocked',
                    'Please settle your tuition fee before accessing Co-Curriculum.',
                  );
                  return;
                }
                Navigator.pop(context);
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
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
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
