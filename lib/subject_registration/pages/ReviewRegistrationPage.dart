import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api.dart';
import '../applications/ApproveRegistration.dart';
import '../applications/RejectRegistration.dart';
import '../../MainDrawer.dart';

class ReviewRegistrationPage extends StatefulWidget {
  final int submissionID;

  const ReviewRegistrationPage({super.key, required this.submissionID});

  @override
  State<ReviewRegistrationPage> createState() => _ReviewRegistrationPageState();
}

class _ReviewRegistrationPageState extends State<ReviewRegistrationPage> {
  Map<String, dynamic>? submissionDetails; 
  List<dynamic> courses = [];
  bool isLoading = true;
  bool isProcessing = false;
  final TextEditingController _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadDetails();
  }

  Future<void> loadDetails() async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/review-submission/${widget.submissionID}'));
      if (!mounted) return;

      // Parse the data no matter what happens
      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        setState(() {
          submissionDetails = data['student'];
          courses = data['courses'];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        // THE FIX: Print the exact Laravel error message on the red banner!
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Server Error: ${data['message'] ?? response.statusCode}"), backgroundColor: Colors.red)
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    }
  }
  
  Future<void> submitDecision(String decision, String? reason) async {
    setState(() => isProcessing = true);
    try {
      if (decision == 'Approve') {
        await ApproveRegistration().executeApprove(widget.submissionID);
      } else {
        await RejectRegistration().executeReject(widget.submissionID, reason ?? '');
      }

      if (!mounted) return;
      setState(() => isProcessing = false);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Registration $decision!"), 
        backgroundColor: decision == 'Approve' ? Colors.green : Colors.orange
      ));
      Navigator.pop(context, true); // Go back to the pending list and refresh!
    } catch (e) {
      if (!mounted) return;
      setState(() => isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    }
  }

  void onRejectClicked() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reject Registration"),
        content: TextField(
          controller: _reasonController,
          decoration: const InputDecoration(hintText: "Enter rejection reason", border: OutlineInputBorder()),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC00000)),
            onPressed: () {
              if (_reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Reason is required"), backgroundColor: Colors.red));
                return;
              }
              Navigator.pop(context);
              submitDecision('Reject', _reasonController.text.trim());
            },
            child: const Text("Confirm Reject", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
  void onApproveClicked() {
    submitDecision('Approve', null);
  }

  Widget render() {
    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (submissionDetails == null) return const Scaffold(body: Center(child: Text("Data not found.")));

    // Calculate total credit hours for the profile card
    int totalCredits = courses.fold(0, (sum, item) => sum + (int.tryParse(item['credit_hours'].toString()) ?? 0));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "REVIEW REGISTRATION", 
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)
        ),
        backgroundColor: const Color(0xFFC3CEC3), // Sage Green
        iconTheme: const IconThemeData(color: Colors.black87),
        elevation: 0,
      ),
      drawer: const MainDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- 1. STUDENT PROFILE CARD ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black54, width: 1),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 3))]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Student Profile", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.account_circle_outlined, size: 42, color: Colors.black87),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(submissionDetails!['student_name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(submissionDetails!['studentID'] ?? '', style: const TextStyle(fontSize: 14)),
                        ],
                      )
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Divider(color: Colors.black26, thickness: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total Credit Hours", style: TextStyle(fontSize: 14, color: Colors.black87)),
                      Text("$totalCredits Credit Hours", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                    ],
                  )
                ],
              ),
            ),
          ),

          // --- 2. REGISTERED SUBJECTS LIST ---
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text("Registered Subjects", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black26, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(course['course_code'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(6)
                            ),
                            child: Text(
                              "Pending", 
                              style: TextStyle(color: Colors.orange.shade800, fontWeight: FontWeight.bold, fontSize: 12)
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(course['course_name'] ?? 'Unknown', style: const TextStyle(fontSize: 14)),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Divider(color: Colors.black12, thickness: 1),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(course['lab_num'] ?? '-', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                          Text("${course['credit_hours']} Credit Hours", style: const TextStyle(fontSize: 14, color: Colors.black87)),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // --- 3. BOTTOM ACTION BUTTONS ---
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -3))]
        ),
        child: isProcessing 
          ? const SizedBox(height: 50, child: Center(child: CircularProgressIndicator()))
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                    ),
                   onPressed: onApproveClicked,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, color: Colors.white),
                        SizedBox(width: 10),
                        Text("Approve Registration", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC00000), // Dark Red
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                    ),
                    onPressed: onRejectClicked,
                    
                    
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cancel_outlined, color: Colors.white),
                        SizedBox(width: 10),
                        Text("Reject Registration", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
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
    return render(); 
  }

}
