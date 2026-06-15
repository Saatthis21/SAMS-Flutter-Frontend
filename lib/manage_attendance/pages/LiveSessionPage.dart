import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../applications/SubmitCheckIn.dart';

class LiveSessionPage extends StatefulWidget {
  final String studentID;
  final int sessionId;
  final String subjectCode;

  const LiveSessionPage({
    Key? key,
    required this.studentID,
    required this.sessionId,
    required this.subjectCode,
  }) : super(key: key);

  @override
  State<LiveSessionPage> createState() => _LiveSessionPageState();
}

class _LiveSessionPageState extends State<LiveSessionPage> {
  final TextEditingController _codeController = TextEditingController();
  final SubmitCheckIn _submitCheckIn = SubmitCheckIn();

  bool _isLoading = false;
  bool _gpsVerified = false;
  double _latitude = 0.0;
  double _longitude = 0.0;

  // Algorithm: captureGPSLocation()
  Future<void> _captureGPSLocation() async {
    setState(() => _isLoading = true);
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception("Location permissions are denied.");
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _gpsVerified = true;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('GPS Location Captured Successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('GPS UNAVAILABLE: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _gpsVerified = false);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Algorithm: submitCheckIn()
  Future<void> _submitAttendance() async {
    if (_codeController.text.isEmpty || _codeController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 6-character code.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_gpsVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please verify your GPS location first.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final record = await _submitCheckIn.execute(
        studentID: widget.studentID,
        sessionId: widget.sessionId,
        submittedCode: _codeController.text,
        gpsLatitude: _latitude,
        gpsLongitude: _longitude,
        gpsVerified: _gpsVerified,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Attendance Successful!'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _codeController.clear();
        _gpsVerified = false; // Reset for security
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- CORRECTLY CONFIGURED APPBAR WITH LEADING BACK BUTTON ---
      appBar: AppBar(
        title: Text('Live Check-in: ${widget.subjectCode}'),
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
      // ------------------------------------------------------------
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter the 6-digit class code provided by your lecturer.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Session Code Input
            TextField(
              controller: _codeController,
              maxLength: 6,
              textCapitalization: TextCapitalization.characters,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 32,
                letterSpacing: 8.0,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),

            // GPS Capture Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _captureGPSLocation,
              icon: Icon(_gpsVerified ? Icons.check_circle : Icons.location_on),
              label: Text(
                _gpsVerified ? 'GPS Verified' : 'Verify GPS Location',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _gpsVerified ? Colors.green : Colors.blue,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 20),

            // Submit Button
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submitAttendance,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Submit Attendance'),
                  ),
          ],
        ),
      ),
    );
  }
}
