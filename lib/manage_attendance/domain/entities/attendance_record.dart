class AttendanceRecord {
  final String checkInStatus;
  final String checkInTime;

  AttendanceRecord({required this.checkInStatus, required this.checkInTime});

  // Factory constructor to easily create an object from Laravel's JSON response
  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      checkInStatus: json['checkInStatus'] ?? 'UNKNOWN',
      checkInTime: json['checkInTime'] ?? '',
    );
  }
}
