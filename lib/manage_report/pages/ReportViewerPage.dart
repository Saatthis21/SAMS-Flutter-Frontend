import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../config/api.dart';

class ReportViewerPage extends StatefulWidget {
  final String reportType;
  final String studentId;
  final String courseCode;

  const ReportViewerPage({
    super.key,
    required this.reportType,
    required this.studentId,
    required this.courseCode,
  });

  @override
  State<ReportViewerPage> createState() => _ReportViewerPageState();
}

class _ReportViewerPageState extends State<ReportViewerPage> {
  bool _isLoading = true;
  List<dynamic> _reportData = [];
  Map<String, dynamic> _summary = {};

  @override
  void initState() {
    super.initState();
    _fetchReport();
  }

  Future<void> _fetchReport() async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.generateReport),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'report_type': widget.reportType,
          'student_id': widget.studentId.isNotEmpty ? widget.studentId : null,
          'course_code': widget.courseCode.isNotEmpty
              ? widget.courseCode
              : null,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          _reportData = data['data'];
          _summary = data['summary'];
          _isLoading = false;
        });
      } else if (response.statusCode == 404) {
        // SAMS-REQ-514: No Data Found Handling
        _showErrorAndExit('No Data Available for the selected criteria.');
      } else {
        _showErrorAndExit(data['message'] ?? 'Failed to load report.');
      }
    } catch (e) {
      _showErrorAndExit('Network error occurred.');
    }
  }

  void _showErrorAndExit(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.reportType.toUpperCase()} REPORT'),
        actions: [
          // SAMS-REQ-511 & 512: Export Buttons
          IconButton(icon: const Icon(Icons.picture_as_pdf), onPressed: () {}),
          IconButton(icon: const Icon(Icons.table_view), onPressed: () {}),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Summary Statistics Card (SAMS-REQ-510)
                Card(
                  margin: const EdgeInsets.all(16),
                  color: Colors.blue[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: _summary.entries.map((entry) {
                        return Text(
                          '${entry.key}: ${entry.value}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // Dynamic Tabular Data (SAMS-REQ-509)
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        columns: _reportData.isNotEmpty
                            ? (_reportData[0] as Map<String, dynamic>).keys
                                  .map(
                                    (key) => DataColumn(
                                      label: Text(
                                        key,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList()
                            : [],
                        rows: _reportData.map((record) {
                          return DataRow(
                            cells: (record as Map<String, dynamic>).values
                                .map(
                                  (value) => DataCell(Text(value.toString())),
                                )
                                .toList(),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
