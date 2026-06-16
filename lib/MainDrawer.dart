import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'LoginPage.dart';
import 'manage_fee/pages/FeeSummaryPage.dart';
import 'subject_registration/pages/AddCoursePage.dart';
import 'subject_registration/pages/PendingRegistrationPage.dart';
import 'manage_attendance/pages/LecturerSessionPage.dart';
import 'manage_attendance/pages/LiveSessionPage.dart';
import 'manage_report/pages/ManageReportDashboard.dart';
import 'manage_cocurriculum/pages/CocurriculumPage.dart';
import 'manage_cocurriculum/pages/PusatAdabPage.dart';

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
    _checkBlockStatus();
  }

  Future<void> _loadRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userRole = prefs.getString('user_role') ?? 'Student';
      _userId = prefs.getString('student_id') ?? 'CB23080';
    });
  }

  Future<void> _checkBlockStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String studentId = prefs.getString('student_id') ?? '';
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

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: _userRole == 'Staff'
                  ? Colors.indigo
                  : _userRole == 'Pusat Adab'
                  ? Colors.red.shade700
                  : Colors.blue.shade800,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  _userRole == 'Staff'
                      ? Icons.admin_panel_settings
                      : _userRole == 'Pusat Adab'
                      ? Icons.verified
                      : Icons.school,
                  color: Colors.white,
                  size: 40,
                ),
                const SizedBox(height: 10),
                Text(
                  _userRole == 'Staff'
                      ? 'UMPSA SAMS\nSTAFF DASHBOARD'
                      : _userRole == 'Pusat Adab'
                      ? 'UMPSA SAMS\nPUSAT ADAB'
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

          // ========================
          // PUSAT ADAB MENU
          // ========================
          if (_userRole == 'Pusat Adab') ...[
            ListTile(
              leading: Icon(Icons.pending_actions, color: Colors.red.shade700),
              title: const Text('Pending Claims'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PusatAdabPage()),
                );
              },
            ),
          ]
          // ========================
          // STAFF MENU
          // ========================
          else if (_userRole == 'Staff') ...[
            ListTile(
              leading: const Icon(Icons.pending_actions),
              title: const Text('Pending Registrations'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => PendingRegistrationPage()),
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
                    builder: (_) => LecturerSessionPage(
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
                    builder: (_) => const ManageReportDashboard(),
                  ),
                );
              },
            ),
          ]
          // ========================
          // STUDENT MENU
          // ========================
          else ...[
            ListTile(
              leading: Icon(
                isBlocked ? Icons.lock : Icons.book,
                color: isBlocked ? Colors.red : Colors.black,
              ),
              title: Text(
                'Subject Registration',
                style: TextStyle(color: isBlocked ? Colors.grey : Colors.black),
              ),
              onTap: () {
                if (isBlocked) {
                  showDialog(
                    context: context,
                    builder: (_) => const AlertDialog(
                      title: Text('Academic Access Blocked'),
                      content: Text(
                        'Please settle your tuition fee before accessing Subject Registration.',
                      ),
                    ),
                  );
                } else {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => AddCoursePage()),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text('Manage Fee'),
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
                'Attendance',
                style: TextStyle(color: isBlocked ? Colors.grey : Colors.black),
              ),
              onTap: () {
                if (isBlocked) {
                  showDialog(
                    context: context,
                    builder: (_) => const AlertDialog(
                      title: Text('Academic Access Blocked'),
                      content: Text(
                        'Please settle your tuition fee before accessing Attendance.',
                      ),
                    ),
                  );
                } else {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LiveSessionPage(
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
                'Co-Curriculum',
                style: TextStyle(color: isBlocked ? Colors.grey : Colors.black),
              ),
              onTap: () {
                if (isBlocked) {
                  showDialog(
                    context: context,
                    builder: (_) => const AlertDialog(
                      title: Text('Academic Access Blocked'),
                      content: Text(
                        'Please settle your tuition fee before accessing Co-Curriculum.',
                      ),
                    ),
                  );
                } else {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CocurriculumPage()),
                  );
                }
              },
            ),
          ],

          const Divider(),

          // ========================
          // LOGOUT
          // ========================
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
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
