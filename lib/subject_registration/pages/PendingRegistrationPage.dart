import 'package:flutter/material.dart';
import '../applications/GetPendingRegistration.dart';
import 'ReviewRegistrationPage.dart';
import '../../MainDrawer.dart';

class PendingRegistrationPage extends StatefulWidget {
  const PendingRegistrationPage({super.key});

  @override
  State<PendingRegistrationPage> createState() => _PendingRegistrationPageState();
}

class _PendingRegistrationPageState extends State<PendingRegistrationPage> {
  List<dynamic> pendingSubmissions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPendingList();
  }

  Future<void> loadPendingList() async {
    setState(() => isLoading = true);

    try {
      final submissions = await GetPendingRegistration().execute();
      
      if (!mounted) return;

      setState(() {
        pendingSubmissions = submissions;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching data: $e"), backgroundColor: Colors.red),
      );
    }
  }

  void onSubmissionTap(int submissionID) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewRegistrationPage(submissionID: submissionID),
      ),
    ).then((_) => loadPendingList()); // This refreshes the list when the Registrar comes back!
  }

  Widget render() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "PENDING REGISTRATION",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: const Color(0xFFC3CEC3), // Light sage green from your mockup
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      drawer: const MainDrawer(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pendingSubmissions.isEmpty
              ? const Center(child: Text("No pending registrations.", style: TextStyle(fontSize: 16)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: pendingSubmissions.length,
                  itemBuilder: (context, index) {
                    final submission = pendingSubmissions[index];
                    return GestureDetector(
                      onTap: () => onSubmissionTap(submission['submissionID']),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black54, width: 1), // Thin outline
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 3),
                            )
                          ]
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top Row: Icon, Name, Matric, Arrow
                            Row(
                              children: [
                                const Icon(Icons.account_circle_outlined, size: 42, color: Colors.black87),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        submission['student_name'] ?? 'Unknown Student',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        submission['studentID'] ?? '',
                                        style: const TextStyle(color: Colors.black87, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.black87),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Bottom Row: Date and Credits
                            Row(
                              children: [
                                const SizedBox(width: 58), // Pushes text over to align under the name
                                const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.black87),
                                const SizedBox(width: 6),
                                Text(
                                  submission['date'] ?? 'N/A',
                                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                                ),
                                const SizedBox(width: 24),
                                const Icon(Icons.school_outlined, size: 18, color: Colors.black87),
                                const SizedBox(width: 6),
                                Text(
                                  "${submission['total_credits'] ?? 0} credit hours",
                                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return render(); 
  }
}

