import 'package:flutter/material.dart';
import 'AttendanceReportPage.dart';
// Note: You would import your InitiateSession application class here

class LecturerSessionPage extends StatefulWidget {
  final String lecturerID;
  final String subjectCode;

  const LecturerSessionPage({
    Key? key,
    required this.lecturerID,
    required this.subjectCode,
  }) : super(key: key);

  @override
  State<LecturerSessionPage> createState() => _LecturerSessionPageState();
}

class _LecturerSessionPageState extends State<LecturerSessionPage> {
  bool _isLoading = false;
  String? _activeSessionCode;
  String? _sessionStatus;

  // Algorithm: startNewSession()
  Future<void> _startNewSession() async {
    setState(() => _isLoading = true);

    try {
      // In your real app, this calls the InitiateSession.execute() method
      // For this UI, we simulate a successful API call generating a code
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _activeSessionCode = "A7X29P"; // Mapped exactly from your UI Wireframe
        _sessionStatus = "ACTIVE";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session Started Successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('SESSION FAILED'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Algorithm: closeSession()
  void _closeSession() {
    setState(() {
      _activeSessionCode = null;
      _sessionStatus = "CLOSED";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage: ${widget.subjectCode}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Go Back',
          onPressed: () {
            // Checks if Flutter has a page history to pop back to
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              // Fallback: If pushed from the Drawer (which destroys history),
              // you can put a custom routing path here to go back to the Main Menu.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please use the Drawer menu to navigate back.'),
                ),
              );
            }
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_activeSessionCode == null) ...[
                // --- INITIAL STATE ---
                const Text(
                  'No active session.',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _startNewSession,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(200, 50),
                        ),
                        child: const Text('Start New Session'),
                      ),
              ] else ...[
                // --- ACTIVE SESSION STATE (Steps 4 & 5) ---
                const Text(
                  'Active Class Code',
                  style: TextStyle(fontSize: 20, color: Colors.grey),
                ),
                Text(
                  _activeSessionCode!,
                  style: const TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 10,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Time Remaining: 14:59',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),

                // STEP 4: DISPLAY ATTENDANCE COUNT
                const SizedBox(height: 20),
                const Text(
                  'Checked In: 2/10',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // STEP 5: REPORT BUTTON (Navigation to AttendanceReportPage)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AttendanceReportPage(
                              lecturerID: widget.lecturerID,
                              subjectCode: widget.subjectCode,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                      ),
                      child: const Text('Report'),
                    ),
                    const SizedBox(width: 20),
                    // CLOSE SESSION BUTTON
                    ElevatedButton(
                      onPressed: _closeSession,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Close Session'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
