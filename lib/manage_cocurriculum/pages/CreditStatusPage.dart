import 'package:flutter/material.dart';
import '../models/cocurriculum_model.dart';

class CreditStatusPage extends StatelessWidget {
  final List<CocurriculumModel> subjects;

  const CreditStatusPage({super.key, required this.subjects});

  int get totalAwarded => subjects
      .where((s) => s.status == 'Credit Awarded')
      .fold(0, (sum, s) => sum + s.credits);

  int get totalPending =>
      subjects.where((s) => s.status == 'Pending Review').length;

  int get totalRejected =>
      subjects.where((s) => s.status == 'Rejected').length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'CREDIT STATUS',
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
                _buildTopCard(
                    totalAwarded.toString(),
                    'Awarded',
                    Colors.green),
                const SizedBox(width: 10),
                _buildTopCard(
                    totalPending.toString(),
                    'Pending',
                    Colors.orange),
                const SizedBox(width: 10),
                _buildTopCard(
                    totalRejected.toString(),
                    'Rejected',
                    Colors.red),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Credit results',
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 12),
            ...subjects.map((s) => _buildStatusCard(s)),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12, blurRadius: 4),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Overall co-curriculum summary',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total credits awarded',
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600),
                      ),
                      Text(
                        '$totalAwarded / ${subjects.length * 2} required',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Graduation requirement',
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: totalAwarded >=
                              subjects.length * 2
                              ? Colors.green.shade100
                              : Colors.orange.shade100,
                          borderRadius:
                          BorderRadius.circular(20),
                        ),
                        child: Text(
                          totalAwarded >= subjects.length * 2
                              ? 'Met'
                              : 'In Progress',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: totalAwarded >=
                                subjects.length * 2
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                  fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(CocurriculumModel subject) {
    Color statusColor;
    IconData statusIcon;
    String statusLabel;

    switch (subject.status) {
      case 'Credit Awarded':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusLabel = 'Credit Awarded';
        break;
      case 'Rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusLabel = 'Claim Rejected';
        break;
      case 'Pending Review':
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
        statusLabel = 'Pending Review';
        break;
      default:
        statusColor = Colors.blue;
        statusIcon = Icons.sports_volleyball;
        statusLabel = 'In Progress';
    }

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
          Row(
            children: [
              Icon(statusIcon,
                  color: statusColor, size: 20),
              const SizedBox(width: 8),
              Text(
                statusLabel,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildRow('Subject', subject.subjectName),
          if (subject.status == 'Credit Awarded')
            _buildRow('Credits awarded',
                '${subject.credits} credits'),
          if (subject.status == 'Credit Awarded')
            _buildRow('Approved by', 'Pusat Adab Staff'),
          if (subject.status == 'Rejected' &&
              subject.rejectionReason != null)
            _buildRow('Reason', subject.rejectionReason!),
          _buildRow('Date', '13 Apr 2026'),
          if (subject.status == 'Rejected') ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                      color: Colors.blue.shade800),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Re-select subject',
                  style: TextStyle(
                      color: Colors.blue.shade800),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
}