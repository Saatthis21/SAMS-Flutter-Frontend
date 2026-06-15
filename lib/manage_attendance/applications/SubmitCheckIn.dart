import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sams_flutter_frontend/config/api.dart';
import '../domain/entities/attendance_record.dart';

class SubmitCheckIn {
  /// Executes the check-in process.
  /// Returns an [AttendanceRecord] if successful, or throws an Exception if failed.
  Future<AttendanceRecord> execute({
    required String studentID,
    required int sessionId,
    required String submittedCode,
    required double gpsLatitude,
    required double gpsLongitude,
    required bool gpsVerified,
  }) async {
    // 1. Validate inputs locally before hitting the server
    if (submittedCode.isEmpty || submittedCode.length != 6) {
      throw Exception('Invalid session code format. Must be 6 characters.');
    }
    if (!gpsVerified) {
      throw Exception('GPS Location not verified. You must be on campus.');
    }

    // 2. Prepare the payload exactly as Laravel expects it
    final Map<String, dynamic> payload = {
      'studentID': studentID,
      'session_id': sessionId,
      'submitted_code': submittedCode,
      'gps_latitude': gpsLatitude,
      'gps_longitude': gpsLongitude,
      'gps_verified': gpsVerified,
    };

    try {
      // Send POST request to Laravel backend
      final response = await http.post(
        Uri.parse(ApiConfig.checkIn),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(payload),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      // Handle Response
      if (response.statusCode == 200 && responseData['status'] == 'success') {
        return AttendanceRecord.fromJson(responseData['data']);
      } else {
        // Throw JUST the clean message from Laravel
        throw responseData['message'] ?? 'Check-in failed.';
      }
    } catch (e) {
      // If the error is already a String (like our clean message above), throw it directly
      if (e is String) throw e;

      // Otherwise, it's a real network crash (like the server being turned off)
      throw 'Network Error: Please check your connection.';
    }
  }
}
