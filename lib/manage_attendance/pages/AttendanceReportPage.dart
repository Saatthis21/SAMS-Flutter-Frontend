import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AttendanceReportPage extends StatefulWidget {
  final String lecturerID;
  final String subjectCode;
  final String section;

  const AttendanceReportPage({
    Key? key,
    required this.lecturerID,
    required this.subjectCode,
    this.section = '01A',
  }) : super(key: key);

  @override
  State<AttendanceReportPage> createState() => _AttendanceReportPageState();
}

class _AttendanceReportPageState extends State<AttendanceReportPage> {
  bool _isLoading = true;
  bool _isExporting = false;
  String _currentFilter = 'All';
  List<Map<String, dynamic>> _attendanceRecords = [];

  @override
  void initState() {
    super.initState();
    _fetchReportData();
  }

  // --- PDF GENERATION ---
  Future<void> _generateAndSharePDF() async {
    final pdf = pw.Document();

    final totalRecords = _attendanceRecords.length;
    final totalPresent = _attendanceRecords
        .where((r) => r['status'] == 'Present')
        .length;
    final totalAbsent = _attendanceRecords
        .where((r) => r['status'] == 'Absent')
        .length;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'ATTENDANCE REPORT: ${widget.subjectCode}',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                color: PdfColors.blue50,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Total Records: $totalRecords'),
                    pw.Text('Total Present: $totalPresent'),
                    pw.Text('Total Absent: $totalAbsent'),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: ['Student ID', 'Name', 'Status'],
                data: _attendanceRecords
                    .map((r) => [r['studentID'], r['name'], r['status']])
                    .toList(),
              ),
            ],
          );
        },
      ),
    );

    // This triggers the native print/share/save dialog
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Report_${widget.subjectCode}.pdf',
    );
  }

  // --- DATA FETCHING ---
  Future<void> _fetchReportData() async {
    setState(() => _isLoading = true);
    try {
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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(
            () => _attendanceRecords = List<Map<String, dynamic>>.from(
              data['data'],
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- UI ---
  @override
  Widget build(BuildContext context) {
    final filteredRecords = _attendanceRecords.where((r) {
      if (_currentFilter == 'All') return true;
      return r['status'] == _currentFilter;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ATTENDANCE REPORT'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => _generateAndSharePDF(), // Explicitly trigger
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filter Button UI omitted for brevity, logic included
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredRecords.length,
                    itemBuilder: (context, index) {
                      final student = filteredRecords[index];
                      final isPresent = student['status'] == 'Present';
                      return Card(
                        child: ListTile(
                          title: Text(student['studentID']),
                          subtitle: Text(student['name']),
                          trailing: Icon(
                            isPresent ? Icons.check_circle : Icons.cancel,
                            color: isPresent ? Colors.green : Colors.grey,
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
