import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/api.dart';
import '../models/cocurriculum_model.dart';
import 'ClaimCreditPage.dart';
import 'CreditStatusPage.dart';

class CocurriculumPage extends StatefulWidget {
  const CocurriculumPage({super.key});

  @override
  State<CocurriculumPage> createState() => _CocurriculumPageState();
}

class _CocurriculumPageState extends State<CocurriculumPage> {
  List<CocurriculumModel> _subjects = [];
  List<Map<String, dynamic>> _availableSubjects = [];
  bool _isLoading = true;
  String _studentID = '';
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _studentID = prefs.getString('student_id') ?? 'CB23080';

    try {
      // Get available subjects
      final availableResponse = await http.get(
        Uri.parse(ApiConfig.getAvailableSubjects),
      );

      // Get registered subjects
      final registeredResponse = await http.get(
        Uri.parse('${ApiConfig.getCocurriculum}/$_studentID'),
      );

      if (availableResponse.statusCode == 200) {
        final List availableData =
        json.decode(availableResponse.body);
        final List registeredData =
        registeredResponse.statusCode == 200
            ? json.decode(registeredResponse.body)
            : [];

        setState(() {
          _availableSubjects = availableData
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
          _subjects = registeredData
              .map((e) => CocurriculumModel.fromJson(e))
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _registerSubject(Map<String, dynamic> subject) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.registerCocurriculum),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'studentID': _studentID,
          'subject_code': subject['subject_code'],
          'subject_name': subject['subject_name'],
        }),
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        _showRegistrationSuccess(subject['subject_name']);
        _loadData();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showRegistrationSuccess(String subjectName) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle,
                color: Colors.green, size: 48),
            const SizedBox(height: 12),
            const Text(
              'Successfully Registered',
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '$subjectName has been added to your co-curriculum record. '
                  'Your attendance will be tracked automatically by the system.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade800,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Done',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'CO-CURRICULUM',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade800,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue.shade800,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() => _currentIndex = index);
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ClaimCreditPage(
                  subjects: _subjects,
                  studentID: _studentID,
                ),
              ),
            ).then((_) {
              setState(() => _currentIndex = 0);
              _loadData();
            });
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    CreditStatusPage(subjects: _subjects),
              ),
            ).then((_) => setState(() => _currentIndex = 0));
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Claim Credit',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Credit Status',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              color: Colors.blue.shade800,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                'Available subjects for your program — Semester 1 2025/2026',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _availableSubjects.length,
              itemBuilder: (context, index) {
                final subject = _availableSubjects[index];
                final isRegistered = _subjects.any(
                      (s) => s.subjectCode == subject['subject_code'],
                );
                return _buildAvailableSubjectCard(
                    subject, isRegistered);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableSubjectCard(
      Map<String, dynamic> subject, bool isRegistered) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject['subject_code'],
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subject['subject_name'],
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.star,
                          size: 13,
                          color: Colors.amber.shade600),
                      const SizedBox(width: 4),
                      Text(
                        '${subject['credits']} Credits',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.people,
                          size: 13,
                          color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        'Slot: ${subject['slots']}',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isRegistered
                    ? Colors.grey.shade300
                    : Colors.blue.shade800,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
              ),
              onPressed: isRegistered
                  ? null
                  : () => _registerSubject(subject),
              child: Text(
                isRegistered ? 'Registered' : 'Register',
                style: TextStyle(
                  color: isRegistered
                      ? Colors.grey
                      : Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}