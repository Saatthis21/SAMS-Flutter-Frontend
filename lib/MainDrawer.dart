import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'subject_registration/pages/AddCoursePage.dart';
import 'subject_registration/pages/PendingRegistrationPage.dart';
import 'LoginPage.dart';

class MainDrawer extends StatefulWidget {
  const MainDrawer({super.key});

  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  String _userRole = 'Student'; // Default

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
                  _userRole == 'Staff' ? Icons.admin_panel_settings : Icons.school, 
                  color: Colors.white, 
                  size: 40
                ),
                const SizedBox(height: 10),
                Text(
                  _userRole == 'Staff' ? 'UMPSA SAMS\nSTAFF DASHBOARD' : 'UMPSA SAMS\nSTUDENT PORTAL',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => PendingRegistrationPage()),
                );
              },
            ),
          ] else ...[
            // SHOW ONLY TO STUDENTS
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Subject Registration'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => AddCoursePage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.how_to_reg),
              title: const Text('Attendance'),
              onTap: () {}, // Arif's module
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