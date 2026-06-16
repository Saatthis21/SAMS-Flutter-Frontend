import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'AttendanceReportPage.dart';
// Note: You would import your InitiateSession application class here
// import '../config/api.dart'; // Uncomment and adjust to your api config file

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
  int? _activeSessionId; // Need this to query the DB
  String? _sessionStatus;

  // --- DYNAMIC VARIABLES ---
  int _checkedInCount = 0;
  final int _totalStudents = 30; // Can be fetched from DB later
  int _secondsRemaining = 900; // 15 minutes = 900 seconds

  Timer? _countdownTimer;
  Timer? _pollingTimer;

  // ALWAYS clean up timers when leaving the page to prevent memory leaks
  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pollingTimer?.cancel();
    super.dispose();
  }

  // Format seconds into MM:SS
  String get _formattedTime {
    int minutes = _secondsRemaining ~/ 60;
    int seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Algorithm: startNewSession()
  Future<void> _startNewSession() async {
    setState(() => _isLoading = true);

    try {
      // In your real app, this calls the InitiateSession.execute() method
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _activeSessionCode = "A7X29P";
        _activeSessionId = 1; // Assuming ID 1 based on your seeder
        _sessionStatus = "ACTIVE";
        _secondsRemaining = 900; // Reset clock
        _checkedInCount = 0; // Reset count
      });

      // 1. START UI CLOCK (Ticks every 1 second)
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_secondsRemaining > 0) {
          setState(() => _secondsRemaining--);
        } else {
          _closeSession(); // Auto-close when time is up
        }
      });

      // 2. START DATABASE POLLING (Ticks every 5 seconds)
      _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
        _fetchLiveAttendanceCount();
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session Started Successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('SESSION FAILED'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Ping Laravel for the current count
  Future<void> _fetchLiveAttendanceCount() async {
    if (_activeSessionId == null) return;

    try {
      // Replace with your actual ApiConfig baseUrl
      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:8000/api/attendance/count/$_activeSessionId',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && mounted) {
          setState(() => _checkedInCount = data['count']);
        }
      }
    } catch (e) {
      debugPrint("Polling error: $e"); // Fails silently in the background
    }
  }

  // Algorithm: closeSession()
  void _closeSession() {
    // Stop timers immediately
    _countdownTimer?.cancel();
    _pollingTimer?.cancel();

    setState(() {
      _activeSessionCode = null;
      _activeSessionId = null;
      _sessionStatus = "CLOSED";
      _checkedInCount = 0;
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
            // WE REMOVED THE BLOCKING LOGIC HERE!
            // Now the lecturer can leave freely.
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
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
                // --- ACTIVE SESSION STATE ---
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

                // DYNAMIC TIMER
                Text(
                  'Time Remaining: $_formattedTime',
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),

                const SizedBox(height: 20),

                // DYNAMIC ATTENDANCE COUNT
                Text(
                  'Checked In: $_checkedInCount/$_totalStudents',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                      child: const Text(
                        'Report',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: _closeSession,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text(
                        'Close Session',
                        style: TextStyle(color: Colors.white),
                      ),
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
