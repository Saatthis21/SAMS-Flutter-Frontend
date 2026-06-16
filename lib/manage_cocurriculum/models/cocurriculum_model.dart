class CocurriculumModel {
  final int id;
  final String studentID;
  final String subjectCode;
  final String subjectName;
  final double hoursRecorded;
  final double hoursRequired;
  final int credits;
  final String status;
  final String? rejectionReason;

  CocurriculumModel({
    required this.id,
    required this.studentID,
    required this.subjectCode,
    required this.subjectName,
    required this.hoursRecorded,
    required this.hoursRequired,
    required this.credits,
    required this.status,
    this.rejectionReason,
  });

  factory CocurriculumModel.fromJson(Map<String, dynamic> json) {
    return CocurriculumModel(
      id: json['id'],
      studentID: json['studentID'],
      subjectCode: json['subject_code'],
      subjectName: json['subject_name'],
      hoursRecorded: double.parse(json['hours_recorded'].toString()),
      hoursRequired: double.parse(json['hours_required'].toString()),
      credits: json['credits'],
      status: json['status'],
      rejectionReason: json['rejection_reason'],
    );
  }
}