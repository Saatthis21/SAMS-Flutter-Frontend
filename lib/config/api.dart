class ApiConfig {
  // 10.0.2.2 is the required IP for an Android Emulator to talk to your local XAMPP/Laravel server
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // Attendance Module Endpoints
  static const String initiateSession = '$baseUrl/attendance/initiateSession';
  static const String checkIn = '$baseUrl/attendance/checkIn';
  static const String getAttendanceReport =
      '$baseUrl/attendance/getAttendanceReport';
  static const String exportSessionData =
      '$baseUrl/attendance/exportSessionData';
}
