import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api.dart';
import '../applications/DropCourse.dart';
import '../applications/GetCourseLabs.dart';
import '../applications/ChangeLabSection.dart';
import '../applications/SubmitRegistration.dart';
import '../domain/entities/LabSection.dart';
import '../../MainDrawer.dart'; // The Main Drawer (for navigation)

class MyRegistrationPage extends StatefulWidget {
  final String studentID;

  const MyRegistrationPage({super.key, required this.studentID});

  @override
  State<MyRegistrationPage> createState() => _MyRegistrationPageState();
}

class _MyRegistrationPageState extends State<MyRegistrationPage> {
  // --- SDD ATTRIBUTES ---
  List<dynamic> draftedCourses = [];
  int totalCreditHours = 20; 
  String? selectedCourse;
  bool isNotifying = false;

  // --- EXTRA VARIABLES ---
  String overallStatus = 'Pending';
  String? rejectionReason;
  bool isLoading = true;
  int? droppingRegisteredID;
  bool _hasMadeChanges = false;


  @override
  void initState() {
    super.initState();
    // MATCHES SDD ALGORITHM: CALL loadRegisteredList
    loadRegisteredList(); 
  }

  // --- DATABASE FETCH FUNCTION (Renamed from render) ---
  Future<void> loadRegisteredList() async {
    setState(() => isLoading = true);

    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/my-courses/${widget.studentID}');
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'success') {
          setState(() {
            draftedCourses = data['data'];
            totalCreditHours = int.tryParse(data['balanceCreditHours']?.toString() ?? '20') ?? 20;
            
            overallStatus = data['overallStatus']?.toString() ??
                            data['overall_status']?.toString() ??
                            _resolveOverallStatus(data['data']);
            isLoading = false;
            rejectionReason = data['rejection_reason']?.toString();
          });
        } else if (data['status'] == 'empty') {
          setState(() {
            draftedCourses = [];
            totalCreditHours = int.tryParse(data['balanceCreditHours']?.toString() ?? '20') ?? 20;
            overallStatus = 'Pending';
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
        }
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Server Error: ${response.statusCode}"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  String _resolveOverallStatus(List<dynamic> courses) {
    if (courses.isEmpty) return 'Pending';
    final statuses = courses.map((course) => (course['status'] ?? course['registration_status'] ?? 'Pending').toString()).toList();
    
    if (statuses.any((s) => s.toLowerCase() == 'rejected')) return 'Rejected';
    if (statuses.every((s) => s.toLowerCase() == 'confirmed')) return 'Confirmed';
    if (statuses.any((s) => s.toLowerCase() == 'pending review')) return 'Pending Review';
    return 'Pending';
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved': return Colors.green.shade600;
      case 'rejected': return Colors.red.shade600;
      default: return Colors.amber.shade700;
    }
  }

  String _value(dynamic value, [String fallback = 'N2']) {
    if (value == null) return fallback;
    final text = value.toString();
    return text.isEmpty ? fallback : text;
  }

  bool get _hasRejectionReason =>
      rejectionReason != null && rejectionReason!.trim().isNotEmpty;

  // --- DROP COURSE LOGIC ---
  void onDropCourse(int registeredID, String courseName) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Drop Course?"),
        content: Text("Are you sure you want to drop $courseName?"),
        actions: [
          TextButton(child: const Text("Cancel"), onPressed: () => Navigator.pop(dialogContext)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text("Drop"),
            onPressed: () async {
              Navigator.pop(dialogContext);
              setState(() => droppingRegisteredID = registeredID);

              final resultMessage = await DropCourse().execute(registeredID);
              if (!mounted) return;
              setState(() => droppingRegisteredID = null);

              if (resultMessage == 'Success') {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Course dropped successfully."), backgroundColor: Colors.green));
                
                setState(() {
                  _hasMadeChanges = true; 
                });
                
                loadRegisteredList(); // <-- Updated to match new function name
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(resultMessage), backgroundColor: Colors.red));
              }
              
            },
          ),
        ],
      ),
    );
  }

  // --- MODIFY COURSE LOGIC ---
  void onModifySection(int registeredID, String courseCode, String currentLabNum) async {
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
    
    try {
      List<LabSection> allLabs = await GetCourseLabs().execute(courseCode);
      if (!mounted) return;
      Navigator.pop(context); // Close spinner

      showModifySectionSelection(context, registeredID, courseCode, allLabs, currentLabNum);

    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    }
  }

  void showModifySectionSelection(BuildContext context, int registeredID, String courseCode, List<LabSection> availableLabs, String currentLabNum) {
    Map<String, List<LabSection>> groupedSections = {};
    Map<int, String> labLetters = {}; 
    
    for (var lab in availableLabs) {
      String fullLabNum = lab.labNum; 
      
      if (fullLabNum.length > 2) {
        String baseSection = fullLabNum.substring(0, fullLabNum.length - 1).trim(); 
        String labLetter = fullLabNum.substring(fullLabNum.length - 1); 
        
        labLetters[lab.labID] = "Lab $labLetter";

        if (!groupedSections.containsKey(baseSection)) groupedSections[baseSection] = [];
        groupedSections[baseSection]!.add(lab);
      } else {
        if (!groupedSections.containsKey(fullLabNum)) groupedSections[fullLabNum] = [];
        groupedSections[fullLabNum]!.add(lab);
        labLetters[lab.labID] = fullLabNum;
      }
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        String? selectedBaseSection; 

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (selectedBaseSection != null)
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => setModalState(() => selectedBaseSection = null),
                        ),
                      Text(
                        selectedBaseSection == null ? "Select Section to Update" : "Select Lab for $selectedBaseSection",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(),

                  if (selectedBaseSection == null)
                    ...groupedSections.keys.map((sectionName) {
                      return ListTile(
                        title: Text(sectionName, style: const TextStyle(fontSize: 16)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => setModalState(() => selectedBaseSection = sectionName),
                      );
                    }).toList(),

                  if (selectedBaseSection != null)
                    ...groupedSections[selectedBaseSection]!.map((lab) {
                      bool isFull = lab.currentCapacity >= lab.maxCapacity;
                      bool isCurrentlySelected = lab.labNum == currentLabNum; 

                      return ListTile(
                        title: Text(
                          labLetters[lab.labID] ?? lab.labNum, 
                          style: const TextStyle(fontWeight: FontWeight.bold)
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${lab.date} at ${lab.time}", style: const TextStyle(color: Colors.black87)),
                            if (lab.date2 != null && lab.time2 != null)
                              Text("${lab.date2!} at ${lab.time2!}", style: const TextStyle(color: Colors.black87)),
                            
                            const SizedBox(height: 4),
                            Text(
                              isCurrentlySelected ? "Current Selection" : "Seats: ${lab.currentCapacity} / ${lab.maxCapacity}",
                              style: TextStyle(
                                color: isCurrentlySelected ? Colors.green.shade700 : (isFull ? Colors.red : Colors.grey.shade600), 
                                fontWeight: FontWeight.bold
                              )
                            ),
                          ],
                        ),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isCurrentlySelected ? Colors.grey.shade400 : (isFull ? Colors.grey : Colors.blue.shade800)
                          ),
                          onPressed: (isFull || isCurrentlySelected) ? null : () {
                            Navigator.pop(context); 
                            _submitModifyRegistration(registeredID, lab.labID); 
                          },
                          child: Text(isCurrentlySelected ? "Current" : (isFull ? "Full" : "Select"), style: const TextStyle(color: Colors.white)),
                        ),
                      );
                    }).toList(),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- SUBMIT MODIFICATION LOGIC ---
  Future<void> _submitModifyRegistration(int registeredID, int newLabID) async {
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));

    try {
      await ChangeLabSection().execute(registeredID, newLabID);

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Update Successfully"), backgroundColor: Colors.green));
      setState(() {
        _hasMadeChanges = true; 
      });
      loadRegisteredList(); // <-- Updated to match new function name
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    }
  }

  // --- NOTIFY LOGIC ---
  Future<void> onNotifyFacultyClicked() async {
    setState(() => isNotifying = true);

    try {
      await SubmitRegistration().execute(widget.studentID);

      if (!mounted) return;
      setState(() => isNotifying = false);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text("Success!"),
          content: const Text("Faculty Notified Successfully. Your registration is now pending review."),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => isNotifying = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    }
  }

  Widget _summaryCard({required Widget child}) {
    return Expanded(
      child: Container(
        height: 98,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: child,
      ),
    );
  }

  Widget _infoItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 5),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
              Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statusBadge(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.16), border: Border.all(color: color), borderRadius: BorderRadius.circular(6)),
      child: Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }

  Widget _courseCard(Map<String, dynamic> course) {
    final registeredID = int.tryParse(course['registeredID']?.toString() ?? '') ?? 0;
    final status = _value(course['status'] ?? course['registration_status'], 'Pending');
    final isDropping = droppingRegisteredID == registeredID;
    final bool isLocked = status != 'Pending' && status != 'Pending Edit';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_value(course['course_code'], '-'), style: const TextStyle(fontSize: 13)),
                    const SizedBox(height: 5),
                    Text(_value(course['course_name'], 'Unknown Course').toUpperCase(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                children: [
                  SizedBox(
                    width: 66, height: 30,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(padding: EdgeInsets.zero, backgroundColor: isLocked ? Colors.grey.shade400 : Colors.blue.shade800, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                      onPressed: isLocked ? null : () => onModifySection(registeredID, _value(course['course_code'], ''), _value(course['lab_num'], '')),
                      child: const Text("Modify", style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 66, height: 30,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(padding: EdgeInsets.zero, backgroundColor: isLocked ? Colors.grey.shade400 : Colors.red.shade300, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                      onPressed: (isDropping || registeredID == 0 || isLocked) ? null : () => onDropCourse(registeredID, _value(course['course_code'], 'this course')),
                      child: isDropping ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text("Drop", style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _infoItem(Icons.group_outlined, "Section", _value(course['section'], _value(course['section_num'], 'N2')))),
              Expanded(child: _infoItem(Icons.menu_book_outlined, "Tutorial/Lab", _value(course['lab_num'], 'N2'))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _infoItem(Icons.schedule_outlined, "Exam Schedule", _value(course['exam_schedule'], _value(course['time'], 'N2')))),
              Expanded(child: _infoItem(Icons.school_outlined, "Credit Hours", "${_value(course['credit_hours'], '0')} Credit")),
            ],
          ),
          const SizedBox(height: 10),
          Align(alignment: Alignment.centerRight, child: _statusBadge(status)),
        ],
      ),
    );
  }

  // --- MATCHES SDD METHOD TABLE: render() ---
  Widget render() {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        title: const Text("MY REGISTRATION", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blue.shade800,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const MainDrawer(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (overallStatus == 'Pending Edit')
                    Container(
                      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        // Blue if we have made changes, Red if there is an active Rejection Reason
                        color: (_hasMadeChanges || !_hasRejectionReason) ? Colors.blue.shade50 : Colors.red.shade50,
                        border: Border.all(
                          color: (_hasMadeChanges || !_hasRejectionReason) ? Colors.blue.shade300 : Colors.red.shade300,
                          width: 1
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            (_hasMadeChanges || !_hasRejectionReason) ? Icons.info_outline : Icons.error_outline,
                            color: (_hasMadeChanges || !_hasRejectionReason) ? Colors.blue.shade700 : Colors.red.shade700,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              (_hasMadeChanges || !_hasRejectionReason) 
                                  ? "Ready to Resubmit: You have made changes." 
                                  : "Registration Rejected: $rejectionReason",
                              style: TextStyle(color: (_hasMadeChanges || !_hasRejectionReason) ? Colors.blue.shade900 : Colors.red.shade900),
                            ),
                          )
                        ],
                      ),
                    ),
                Container(
                  color: Colors.grey.shade200,
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
                  child: Row(
                    children: [
                      _summaryCard(
                        child: Row(
                          children: [
                            Text("$totalCreditHours", style: TextStyle(fontSize: 40, color: Colors.blue.shade800, fontWeight: FontWeight.w300)),
                            const SizedBox(width: 12),
                            const Expanded(child: Text("Balance\nCredit\nHours", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, height: 1.2))),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      _summaryCard(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Overall Status:", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 6),
                            Text(overallStatus, style: TextStyle(fontSize: 14, color: _statusColor(overallStatus), fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: draftedCourses.isEmpty
                      ? const Center(child: Text("No courses drafted yet."))
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 12, bottom: 8),
                          itemCount: draftedCourses.length,
                          itemBuilder: (context, index) {
                            final course = Map<String, dynamic>.from(draftedCourses[index]);
                            return _courseCard(course);
                          },
                        ),
                ),
                Container(
                  color: Colors.grey.shade200,
                  padding: const EdgeInsets.fromLTRB(28, 12, 28, 18),
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      foregroundColor: Colors.grey.shade300,
                      backgroundColor: Colors.blue.shade800,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: draftedCourses.isEmpty || isNotifying ? null : onNotifyFacultyClicked,
                    child: isNotifying
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text("Notify", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
    );
  }

  // --- FLUTTER NATIVE REQUIREMENT ---
  @override
  Widget build(BuildContext context) {
    return render(); 
  }
}