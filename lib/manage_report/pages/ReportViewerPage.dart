import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
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

  // --- PDF GENERATION LOGIC ---
  Future<void> _generatePdf() async {
    final pdf = pw.Document();

    // Get table headers dynamically from the first record
    final headers = _reportData.isNotEmpty
        ? (_reportData[0] as Map<String, dynamic>).keys.toList()
        : [];

    // Get rows dynamically
    final tableData = _reportData.map((row) {
      return (row as Map<String, dynamic>).values
          .map((val) => val.toString())
          .toList();
    }).toList();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text(
                '${widget.reportType.toUpperCase()} REPORT',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(headers: headers, data: tableData),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: '${widget.reportType}_Report.pdf',
    );
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
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _reportData.isNotEmpty
                ? _generatePdf
                : null, // Enabled only if data exists
          ),
          IconButton(icon: const Icon(Icons.table_view), onPressed: () {}),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
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
