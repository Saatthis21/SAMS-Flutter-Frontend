class Course {
  final String courseCode;
  final String courseName;
  final int creditHours;

  Course({
    required this.courseCode,
    required this.courseName,
    required this.creditHours,
  });

  // Translates the JSON from Laravel into a Flutter object
  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      courseCode: json['course_code'],
      courseName: json['course_name'],
      creditHours: json['credit_hours'],
    );
  }
}