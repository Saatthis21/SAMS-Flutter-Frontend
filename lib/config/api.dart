class ApiConfig {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // Attendance Module Endpoints
  static const String initiateSession = '$baseUrl/attendance/initiateSession';
  static const String checkIn = '$baseUrl/attendance/checkIn';
  static const String getAttendanceReport = '$baseUrl/attendance/getAttendanceReport';
  static const String exportSessionData = '$baseUrl/attendance/exportSessionData';

  // Manage Reports Endpoints
  static const String generateReport = '$baseUrl/reports/generate';

  // Co-curriculum Endpoints (Aida - CB23080)
  static const String getCocurriculum = '$baseUrl/cocurriculum';
  static const String getAvailableSubjects = '$baseUrl/cocurriculum/available';
  static const String registerCocurriculum = '$baseUrl/cocurriculum/register';
  static const String claimCredit = '$baseUrl/cocurriculum/claim';
  static const String approveCredit = '$baseUrl/cocurriculum/approve';
  static const String rejectCredit = '$baseUrl/cocurriculum/reject';
  static const String getPendingClaims = '$baseUrl/cocurriculum/pending/all';
}