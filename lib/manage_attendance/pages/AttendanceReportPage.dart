import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Added HTTP package

// Note: Import your actual application classes here in your real project
// import '../applications/ExportSessionData.dart';

class AttendanceReportPage extends StatefulWidget {
  final String lecturerID;
  final String subjectCode;
  final String section;

  const AttendanceReportPage({
    Key? key,
    required this.lecturerID,
    required this.subjectCode,
    this.section = '01A', // Defaulting based on the wireframe
  }) : super(key: key);

  @override
  State<AttendanceReportPage> createState() => _AttendanceReportPageState();
}

class _AttendanceReportPageState extends State<AttendanceReportPage> {
  bool _isLoading = true;
  bool _isExporting = false;
  String _currentFilter = 'All'; // Can be 'All', 'Present', or 'Absent'

  // This will now hold live data from the database
  List<Map<String, dynamic>> _attendanceRecords = [];

  @override
  void initState() {
    super.initState();
    _fetchReportData();
  }

  // Algorithm: getAttendanceReport() - NOW LIVE!
  Future<void> _fetchReportData() async {
    setState(() => _isLoading = true);

    try {
      // 1. MAKE THE REAL API CALL TO LARAVEL
      // NOTE: Using 10.0.2.2 for Android Emulator testing
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/attendance/getAttendanceReport'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'lecturer_id': widget.lecturerID,
          'subject_code': widget.subjectCode,
          'section': widget.section,
        }),
      );

      // 2. PARSE THE REAL DATABASE DATA
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          setState(() {
            // Overwrite the list with the real data from Laravel!
            _attendanceRecords = List<Map<String, dynamic>>.from(data['data']);
          });
        } else {
          throw Exception(
            data['message'] ?? 'Failed to fetch attendance data.',
          );
        }
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint(
        'REPORT NETWORK CRASH: $e',
      ); // Helpful for debugging in VS Code
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load report: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Algorithm: exportSessionData()
  Future<void> _exportReport() async {
    setState(() => _isExporting = true);

    try {
      // In production, call ExportSessionData.execute() here.
      await Future.delayed(
        const Duration(seconds: 2),
      ); // Simulate file generation

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report exported successfully to Downloads folder!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Export failed.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  // UI Helper: Filter Bottom Sheet
  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Text(
                  'Filter Attendance',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.list, color: Colors.blue),
                title: const Text('All Students'),
                onTap: () {
                  setState(() => _currentFilter = 'All');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text('Present Only'),
                onTap: () {
                  setState(() => _currentFilter = 'Present');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.grey),
                title: const Text('Absent Only'),
                onTap: () {
                  setState(() => _currentFilter = 'Absent');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Apply the active filter to the display list
    final filteredRecords = _attendanceRecords.where((record) {
      if (_currentFilter == 'All') return true;
      return record['status'] == _currentFilter;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('REPORT ATTENDANCE'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Go Back',
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please use the Drawer menu to navigate back.'),
                ),
              );
            }
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Top Header Card (Subject info and action buttons)
                Card(
                  margin: const EdgeInsets.all(16.0),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.subjectCode} ${widget.section}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            // Export Button
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isExporting ? null : _exportReport,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[800],
                                  foregroundColor: Colors.white,
                                ),
                                child: _isExporting
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text('EXPORT'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Filter Button
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _showFilterOptions,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[400],
                                  foregroundColor: Colors.black87,
                                ),
                                child: Text(
                                  'FILTER: ${_currentFilter.toUpperCase()}',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Student List
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredRecords.length,
                    itemBuilder: (context, index) {
                      final student = filteredRecords[index];
                      final isPresent = student['status'] == 'Present';

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 6.0,
                        ),
                        elevation: 1,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          title: Text(
                            student['studentID'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            student['name'],
                            style: const TextStyle(fontSize: 13),
                          ),
                          trailing: Icon(
                            isPresent ? Icons.check_circle : Icons.cancel,
                            color: isPresent ? Colors.green : Colors.grey,
                            size: 32,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
