import 'package:flutter/material.dart';
import 'subject_registration/pages/AddCoursePage.dart'; // Adjust path if needed
import 'LoginPage.dart';


class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue, // Your app's primary color
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.school, color: Colors.white, size: 40),
                SizedBox(height: 10),
                Text(
                  'UMPSA SAMS',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ],
            ),
          ),
          // Your Module
          ListTile(
            leading: const Icon(Icons.book),
            title: const Text('Subject Registration'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AddCoursePage()), // Update with your actual page name
              );
            },
          ),
          // Arif's Module Placeholder
          ListTile(
            leading: const Icon(Icons.how_to_reg),
            title: const Text('Attendance'),
            onTap: () {
              // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AttendancePage()));
            },
          ),
          // Arifah's Module Placeholder
          ListTile(
            leading: const Icon(Icons.sports_volleyball),
            title: const Text('Co-Curriculum'),
            onTap: () {
              // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CoCurriculumPage()));
            },
          ),
          const Divider(),
          // Logout Button
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              // Send back to the front door
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
                (route) => false, 
              );
            },
          ),
        ],
      ),
    );
  }
}