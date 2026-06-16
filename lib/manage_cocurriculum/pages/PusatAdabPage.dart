import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../config/api.dart';

class PusatAdabPage extends StatefulWidget {
  const PusatAdabPage({super.key});

  @override
  State<PusatAdabPage> createState() => _PusatAdabPageState();
}

class _PusatAdabPageState extends State<PusatAdabPage> {
  List _pendingClaims = [];
  bool _isLoading = true;
  int _pending = 0;
  int _approved = 0;
  int _rejected = 0;

  @override
  void initState() {
    super.initState();
    _loadClaims();
  }

  Future<void> _loadClaims() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.getPendingClaims}'),
      );
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          _pendingClaims = data;
          _pending = data
              .where((c) => c['status'] == 'Pending Review')
              .length;
          _approved = data
              .where((c) => c['status'] == 'Credit Awarded')
              .length;
          _rejected =
              data.where((c) => c['status'] == 'Rejected').length;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _approve(int id) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.approveCredit}/$id'),
        headers: {'Content-Type': 'application/json'},
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Credit Awarded Successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          _loadClaims();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _reject(int id) async {
    final TextEditingController reasonController =
    TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reject Claim'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please enter rejection reason:'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter reason...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              Navigator.pop(context);
              try {
                final response = await http.post(
                  Uri.parse('${ApiConfig.rejectCredit}/$id'),
                  headers: {'Content-Type': 'application/json'},
                  body: json.encode(
                      {'reason': reasonController.text}),
                );
                final data = json.decode(response.body);
                if (response.statusCode == 200 &&
                    data['success'] == true) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Claim Rejected'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    _loadClaims();
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Reject',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showClaimDetail(Map claim) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${claim['studentID']}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Pending',
                    style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            const Text(
              'Claim information',
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Subject',
                claim['subject_name'] ?? ''),
            _buildDetailRow('Subject code',
                claim['subject_code'] ?? ''),
            _buildDetailRow('Total hours recorded',
                '${claim['hours_recorded']} hrs'),
            _buildDetailRow('Minimum required',
                '${claim['hours_required']} hrs'),
            _buildDetailRow('Credits to award',
                '${claim['credits']} credits'),
            _buildDetailRow('Status', 'Pending review'),
            const SizedBox(height: 20),
            const Text(
              'Participation records',
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            _buildAttendanceRow(
                'Training session', '+2 hrs', '10 Apr 2026'),
            _buildAttendanceRow(
                'Training session', '+2 hrs', '7 Apr 2026'),
            _buildAttendanceRow(
                'Tournament', '+4 hrs', '3 Apr 2026'),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _approve(claim['id']);
                    },
                    child: const Text(
                      'Approve',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _reject(claim['id']);
                    },
                    child: const Text(
                      'Reject',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13, color: Colors.grey.shade600)),
          Text(value,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAttendanceRow(
      String title, String hours, String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 13)),
          Row(
            children: [
              Text(hours,
                  style: const TextStyle(
                      fontSize: 13,
                      color: Colors.green,
                      fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              Text(date,
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'PENDING CLAIMS',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadClaims,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header stats
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade700,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Co-curriculum credit claim requests',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                            _pending.toString(),
                            'Pending',
                            Colors.orangeAccent),
                        _buildStatItem(
                            _approved.toString(),
                            'Approved',
                            Colors.greenAccent),
                        _buildStatItem(
                            _rejected.toString(),
                            'Rejected',
                            Colors.white),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Pending review (${_pending})',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
              const SizedBox(height: 12),

              // Claims list
              _pendingClaims.isEmpty
                  ? Center(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Icon(Icons.check_circle,
                        size: 64,
                        color: Colors.green.shade300),
                    const SizedBox(height: 16),
                    const Text(
                      'No pending claims!',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                shrinkWrap: true,
                physics:
                const NeverScrollableScrollPhysics(),
                itemCount: _pendingClaims.length,
                itemBuilder: (context, index) {
                  final claim = _pendingClaims[index];
                  return _buildClaimCard(claim);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(
              color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildClaimCard(Map claim) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${claim['studentID']}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Pending',
                    style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              claim['subject_name'] ?? '',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              '${claim['hours_recorded']} hrs recorded  •  ${claim['credits']} credits',
              style: TextStyle(
                  fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Text(
              '${claim['hours_recorded']} / ${claim['hours_required']} hrs — threshold met',
              style: const TextStyle(
                  fontSize: 12, color: Colors.green),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red.shade700),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => _showClaimDetail(claim),
                child: Text(
                  'Review',
                  style:
                  TextStyle(color: Colors.red.shade700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}