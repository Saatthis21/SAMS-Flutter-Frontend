import 'package:flutter/material.dart';
import 'ReportViewerPage.dart';

class ManageReportDashboard extends StatefulWidget {
  const ManageReportDashboard({super.key});

  @override
  State<ManageReportDashboard> createState() => _ManageReportDashboardState();
}

class _ManageReportDashboardState extends State<ManageReportDashboard> {
  String _selectedReportType = 'attendance';
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();

  void _generateReport() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportViewerPage(
          reportType: _selectedReportType,
          studentId: _studentIdController.text,
          courseCode: _courseController.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Reports')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            const Text(
              'Select Report Type',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: _selectedReportType,
              isExpanded: true,
              items: const [
                DropdownMenuItem(
                  value: 'attendance',
                  child: Text('Attendance Report'),
                ),
                DropdownMenuItem(
                  value: 'registration',
                  child: Text('Course Registration Report'),
                ),
                DropdownMenuItem(
                  value: 'fee',
                  child: Text('Fee Payment Report'),
                ),
                DropdownMenuItem(
                  value: 'cocurriculum',
                  child: Text('Co-curriculum Report'),
                ),
              ],
              onChanged: (val) => setState(() => _selectedReportType = val!),
            ),
            const SizedBox(height: 20),

            const Text(
              'Optional Filters',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _studentIdController,
              decoration: const InputDecoration(
                labelText: 'Student ID (e.g., CB23102)',
              ),
            ),
            TextField(
              controller: _courseController,
              decoration: const InputDecoration(
                labelText: 'Course Code (e.g., BCS2173)',
              ),
            ),

            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _generateReport,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Generate Report'),
            ),
          ],
        ),
      ),
    );
  }
}
