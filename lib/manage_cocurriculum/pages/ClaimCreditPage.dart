import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../config/api.dart';
import '../models/cocurriculum_model.dart';

class ClaimCreditPage extends StatefulWidget {
  final List<CocurriculumModel> subjects;
  final String studentID;

  const ClaimCreditPage({
    super.key,
    required this.subjects,
    required this.studentID,
  });

  @override
  State<ClaimCreditPage> createState() => _ClaimCreditPageState();
}

class _ClaimCreditPageState extends State<ClaimCreditPage> {
  bool _isLoading = false;

  int get totalHours => widget.subjects
      .fold(0, (sum, s) => sum + s.hoursRecorded.toInt());

  int get creditsClaimed => widget.subjects
      .where((s) => s.status == 'Credit Awarded')
      .fold(0, (sum, s) => sum + s.credits);

  Future<void> _claimCredit(CocurriculumModel subject) async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.claimCredit}/${subject.id}'),
        headers: {'Content-Type': 'application/json'},
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200 &&
          data['success'] == true) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ClaimSubmittedPage(subject: subject),
            ),
          );
        }
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
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'CLAIM CREDIT',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade800,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildTopCard(totalHours.toString(),
                    'Hours Recorded', Colors.blue.shade800),
                const SizedBox(width: 10),
                _buildTopCard(
                    '$creditsClaimed / ${widget.subjects.length * 2}',
                    'Credits Claimed',
                    Colors.blue.shade800),
                const SizedBox(width: 10),
                _buildTopCard(
                    'Active', 'Status', Colors.blue.shade800),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'My co-curriculum subjects',
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 12),
            ...widget.subjects
                .map((s) => _buildProgressCard(s)),
            const SizedBox(height: 20),
            const Text(
              'Recent attendance',
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            _buildRecentAttendance(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCard(
      String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(CocurriculumModel subject) {
    double progress =
        subject.hoursRecorded / subject.hoursRequired;
    bool canClaim =
        subject.hoursRecorded >= subject.hoursRequired &&
            subject.status == 'In Progress';
    bool isPending = subject.status == 'Pending Review';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subject.subjectCode,
            style: TextStyle(
                fontSize: 11, color: Colors.grey.shade500),
          ),
          Text(
            subject.subjectName,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hours progress',
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600),
              ),
              Text(
                '${subject.hoursRecorded.toInt()} / ${subject.hoursRequired.toInt()} hrs',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress > 1.0 ? 1.0 : progress,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              color: progress >= 1.0
                  ? Colors.green
                  : Colors.blue.shade800,
            ),
          ),
          const SizedBox(height: 6),
          if (canClaim)
            const Text(
              'Threshold met — eligible to claim',
              style: TextStyle(
                  fontSize: 11, color: Colors.green),
            )
          else if (isPending)
            const Text(
              'Pending Pusat Adab review',
              style: TextStyle(
                  fontSize: 11, color: Colors.orange),
            )
          else
            Text(
              '${(subject.hoursRequired - subject.hoursRecorded).toInt()} more hours needed to claim',
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600),
            ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: canClaim
                    ? Colors.blue.shade800
                    : Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: canClaim && !_isLoading
                  ? () => _claimCredit(subject)
                  : null,
              child: Text(
                'Claim Credit — ${subject.subjectName}',
                style: TextStyle(
                  color: canClaim
                      ? Colors.white
                      : Colors.grey,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAttendance() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4),
        ],
      ),
      child: Column(
        children: [
          _buildAttendanceRow(
              'Training session: Badminton',
              '+2 hrs',
              '10 Apr'),
          _buildAttendanceRow(
              'Training session: Badminton',
              '+2 hrs',
              '7 Apr'),
          _buildAttendanceRow(
              'Tournament: Badminton', '+4 hrs', '3 Apr'),
          _buildAttendanceRow(
              'Training session: Badminton',
              '+2 hrs',
              '1 Apr'),
          _buildAttendanceRow(
              'Community activity', '+3 hrs', '28 Mar'),
        ],
      ),
    );
  }

  Widget _buildAttendanceRow(
      String title, String hours, String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 13)),
          Row(
            children: [
              Text(
                hours,
                style: const TextStyle(
                    fontSize: 13,
                    color: Colors.green,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              Text(
                date,
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================
// CLAIM SUBMITTED PAGE
// =============================================
class ClaimSubmittedPage extends StatelessWidget {
  final CocurriculumModel subject;

  const ClaimSubmittedPage(
      {super.key, required this.subject});

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'CLAIM CREDIT',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade800,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
                border:
                Border.all(color: Colors.green.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle,
                      color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Claim submitted — awaiting Pusat Adab review',
                      style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Claim summary',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),
                  const Divider(height: 20),
                  _buildRow('Subject', subject.subjectName),
                  _buildRow(
                      'Subject code', subject.subjectCode),
                  _buildRow('Total hours',
                      '${subject.hoursRecorded.toInt()} hrs'),
                  _buildRow('Credits to claim',
                      '${subject.credits} credits'),
                  _buildRow(
                    'Submitted on',
                    '${DateTime.now().day} ${_monthName(DateTime.now().month)} ${DateTime.now().year}',
                  ),
                  _buildStatusRow(
                      'Status', 'Pending review'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Pusat Adab staff has been notified of your claim. '
                    'You will receive a notification once it is reviewed and processed.',
                style: TextStyle(
                    fontSize: 13, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600)),
          Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600)),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Pending review',
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}