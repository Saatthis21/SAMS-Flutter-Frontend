import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // The Vault
import '../domain/entities/Course.dart';
import '../domain/entities/LabSection.dart';
import '../applications/GetAvailableCourses.dart';
import '../applications/AddCourse.dart';
import '../applications/GetCourseLabs.dart';
import 'MyRegistrationPage.dart';
import '../../MainDrawer.dart'; // The Main Drawer (for navigation)


class AddCoursePage extends StatefulWidget {
  const AddCoursePage({super.key});

  @override
  _AddCoursePageState createState() => _AddCoursePageState();
}

class _AddCoursePageState extends State<AddCoursePage> {
  List<Course> _availableCourses = [];
  bool _isLoading = true;

  // Variables to hold the logged-in student's data
  String _studentId = "Loading...";
  String _studentName = "Loading...";
  String _studentCourse = "Loading...";
  int _studentYear = 0;

  @override
  void initState() {
    super.initState();
    _loadStudentData(); // 1. Load the student info from the vault
    _loadCourse();      // 2. Load the courses from Laravel
  }

  // --- READ THE VAULT ---
  Future<void> _loadStudentData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _studentId = prefs.getString('student_id') ?? "Unknown ID";
      _studentName = prefs.getString('student_name') ?? "Unknown Name";
      _studentCourse = prefs.getString('student_course') ?? "Unknown Course";
      _studentYear = prefs.getInt('student_year') ?? 0;
    });
  }

  Future<void> _loadCourse() async {
    final courses = await GetAvailableCourses().execute();
    setState(() {
      _availableCourses = courses;
      _isLoading = false;
    });
  }

  Future<void> onRegisterClicked(String courseCode) async {
    showDialog(context: context, builder: (_) => const Center(child: CircularProgressIndicator()));

    try {
      // 1. Fetch the data as proper LabSection objects
      List<LabSection> allLabs = await GetCourseLabs().execute(courseCode);
      Navigator.pop(context); // Close loading dialog

      // 2. Pass it directly to our new dynamic 2-step bottom sheet
      showSectionSelection(context, courseCode, allLabs);

    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    }
  }

  void showSectionSelection(BuildContext context, String courseCode, List<LabSection> availableLabs) {
    // 1. DYNAMICALLY GROUP THE OBJECTS
    Map<String, List<LabSection>> groupedSections = {};
    Map<int, String> labLetters = {}; // Stores just the letter (e.g., "Lab A")
    
    for (var lab in availableLabs) {
      String fullLabNum = lab.labNum; // e.g., "Section 01A"
      
      // Safety check just in case a lab is named something weird like "A"
      if (fullLabNum.length > 2) {
        String baseSection = fullLabNum.substring(0, fullLabNum.length - 1).trim(); // "Section 01"
        String labLetter = fullLabNum.substring(fullLabNum.length - 1); // "A"
        
        labLetters[lab.labID] = "Lab $labLetter";

        if (!groupedSections.containsKey(baseSection)) {
          groupedSections[baseSection] = [];
        }
        groupedSections[baseSection]!.add(lab);
      } else {
        // Fallback
        if (!groupedSections.containsKey(fullLabNum)) groupedSections[fullLabNum] = [];
        groupedSections[fullLabNum]!.add(lab);
        labLetters[lab.labID] = fullLabNum;
      }
    }

    // 2. SHOW THE 2-STEP BOTTOM SHEET
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
                  // --- HEADER ---
                  Row(
                    children: [
                      if (selectedBaseSection != null)
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => setModalState(() => selectedBaseSection = null), // Go back to Step 1
                        ),
                      Text(
                        selectedBaseSection == null ? "Select Section" : "Select Lab for $selectedBaseSection",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(),

                  // --- STEP 1: SHOW ONLY SECTIONS (01, 02) ---
                  if (selectedBaseSection == null)
                    ...groupedSections.keys.map((sectionName) {
                      return ListTile(
                        title: Text(sectionName, style: const TextStyle(fontSize: 16)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Move to Step 2
                          setModalState(() => selectedBaseSection = sectionName);
                        },
                      );
                    }),

                  // --- STEP 2: SHOW LABS FOR CHOSEN SECTION ---
                  if (selectedBaseSection != null)
                    ...groupedSections[selectedBaseSection]!.map((lab) {
                      bool isFull = lab.currentCapacity >= lab.maxCapacity;

                      return ListTile(
                        title: Text(
                          labLetters[lab.labID] ?? lab.labNum, 
                          style: const TextStyle(fontWeight: FontWeight.bold)
                        ),
                        // ---- PASTE THE NEW SUBTITLE HERE ----
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${lab.date} at ${lab.time}", style: const TextStyle(color: Colors.black87)),
                            // Only show the second date if it actually exists!
                            if (lab.date2 != null && lab.time2 != null)
                              Text("${lab.date2!} at ${lab.time2!}", style: const TextStyle(color: Colors.black87)),
                            
                            const SizedBox(height: 4),
                            Text(
                              "Seats: ${lab.currentCapacity} / ${lab.maxCapacity}",
                              style: TextStyle(color: isFull ? Colors.red : Colors.grey.shade600, fontWeight: FontWeight.bold)
                            ),
                          ],
                        ),
                        
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isFull ? Colors.grey : Colors.blue.shade800
                          ),
                          onPressed: isFull ? null : () {
                            Navigator.pop(context); // Close sheet
                            // Call your real database submission function
                            _submitCourseRegistration(courseCode, lab.labID); 
                          },
                          child: Text(isFull ? "Full" : "Select", style: const TextStyle(color: Colors.white)),
                        ),
                      );
                    }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- SEND TO DATABASE (NOW USING THE REAL STUDENT ID!) ---
  Future<void> _submitCourseRegistration(String courseCode, int realLabID) async {
    // We removed "CB23019". It now uses the ID of whoever is logged in!
    showDialog(context: context, builder: (_) => const Center(child: CircularProgressIndicator()));
    
    String resultMessage = await AddCourse().execute(_studentId, courseCode, realLabID);
    
    Navigator.pop(context);

    if (resultMessage == "Success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Course added successfully!"), backgroundColor: Colors.green)
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resultMessage), backgroundColor: Colors.red)
      );
    }
  }

  // --- HELPER WIDGET FOR THE INFO CARD ---
  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          SizedBox(
            width: 100, 
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))
          ),
          Container(height: 20, width: 1, color: Colors.grey.shade400, margin: const EdgeInsets.symmetric(horizontal: 8)),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  // --- THE NEW UI WITH THE CARD ---
@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        
        title: const Text('ADD COURSE', style: TextStyle(fontWeight: FontWeight.bold)),
        
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        // --- WE ADDED THE ACTIONS LIST RIGHT HERE ---
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt), 
            tooltip: 'My Registration Cart',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyRegistrationPage(studentID: _studentId),
                ),
              );
            },
          ),
        ],
        // --- END OF NEW BUTTON ---
      ),
      drawer: const MainDrawer(),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : Column(
            children: [
              // THE STUDENT INFO CARD
              Container(
                margin: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildInfoRow("NAME", "$_studentId - $_studentName"),
                    const Divider(height: 1, thickness: 1),
                    _buildInfoRow("PROGRAMME", _studentCourse),
                    const Divider(height: 1, thickness: 1),
                    _buildInfoRow("YEAR", "Year $_studentYear"),
                  ],
                ),
              ),

              // THE COURSE LIST
              Expanded(
                child: ListView.builder(
                  itemCount: _availableCourses.length,
                  itemBuilder: (context, index) {
                    final course = _availableCourses[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                      child: ListTile(
                        title: Text("${course.courseCode} - ${course.courseName}", style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Credit Hours: ${course.creditHours}"),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade800),
                          onPressed: () => onRegisterClicked(course.courseCode),
                          child: const Text("Register", style: TextStyle(color: Colors.white)),
                          
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
